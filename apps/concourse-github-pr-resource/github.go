package resource

import (
	"context"
	"crypto/tls"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net/http"
	"net/url"
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"github.com/DataDog/datadog-api-client-go/v2/api/datadog"
	"github.com/DataDog/datadog-api-client-go/v2/api/datadogV2"
	"github.com/google/go-github/github"
	"github.com/gregjones/httpcache"
	"github.com/gregjones/httpcache/diskcache"
	vault "github.com/hashicorp/vault/api"
	auth "github.com/hashicorp/vault/api/auth/approle"
	"github.com/shurcooL/githubv4"
	"golang.org/x/oauth2"
)

// on-disk location to store cached API results in between invocations, in OS-specific temp folder.
// primarily useful for the Check command, which will be re-run in the same container multiple times
// the underlying disk caching library (diskv via httpcache) automatically finds-or-creates this directory.
// failures to write cache are silently ignored.
const diskCacheFolder = "github-api-cache"

// Github for testing purposes.
//
//go:generate go run github.com/maxbrunsfeld/counterfeiter/v6 -o fakes/fake_github.go . Github
type Github interface {
	ListPullRequests([]githubv4.PullRequestState) ([]*PullRequest, error)
	ListModifiedFiles(int) ([]string, error)
	PostComment(string, string) error
	GetPullRequest(string, string) (*PullRequest, error)
	GetChangedFiles(string, string) ([]ChangedFileObject, error)
	UpdateCommitStatus(string, string, string, string, string, string) error
	DeletePreviousComments(string) error
}

// GithubClient for handling requests to the Github V3 and V4 APIs.
type GithubClient struct {
	V3         *github.Client
	V4         *githubv4.Client
	Repository string
	Owner      string
}

// NewGithubClient ...
func NewGithubClient(s *Source) (*GithubClient, error) {
	owner, repository, err := parseRepository(s.Repository)
	if err != nil {
		return nil, err
	}
	// Github rate limit check
	// check if the passed AccessToken has availablility
	// if that threshold is below a certain number
	// use AccessTokenAdditional
	var skipAccessToken = false
	var minRemainingThresholdBeforeUsingAccessTokenAdditional = DefaultMinRemainingBeforeUsingAccessTokenAdditional
	if s.OdAdvanced.MinRemainingThresholdBeforeUsingAccessTokenAdditional == 0 {
		log.Printf("source.min_remaining_threshold_before_using_access_token_additional was not supplied in pipeline ... "+
			"using DefaultMinRemainingBeforeUsingAccessTokenAdditional : %d\n", DefaultMinRemainingBeforeUsingAccessTokenAdditional)
	} else {
		log.Printf("using source.min_remaining_threshold_before_using_access_token_additional : %d\n", s.OdAdvanced.MinRemainingThresholdBeforeUsingAccessTokenAdditional)
		minRemainingThresholdBeforeUsingAccessTokenAdditional = s.OdAdvanced.MinRemainingThresholdBeforeUsingAccessTokenAdditional
		if minRemainingThresholdBeforeUsingAccessTokenAdditional >= 20000 {
			log.Printf("Skipping accessToken as minRemainingThresholdBeforeUsingAccessTokenAdditional >= 20000")
			skipAccessToken = true
		}
	}
	log.Printf("current AccessToken : %s_REDACTED\n", s.AccessToken[0:10])
	log.Printf("If the AccessToken starts with 'ghp_', it is a GitHub Personal token\n")
	log.Printf("If the AccessToken starts with 'ghs_', it is a GitHub App token - which has a higher rateLimit and is more secure\n")
	if skipAccessToken {
		s.AccessToken, err = getAccessTokenFromVault(*s)
		if err != nil {
			log.Printf("There is a problem with vault %s\n", err)
			return nil, err
		}
		log.Printf("new AccessToken : %s_REDACTED\n", s.AccessToken[0:10])
		PrintCurrentRateLimit(*s)
	} else {
		coreRemaining, graphqlRemaining, _ := getRateLimit(*s)
		log.Printf("Github rateLimit coreRemaining : %d, graphqlRemaining : %d\n", coreRemaining, graphqlRemaining)
		minRemaining := coreRemaining
		if graphqlRemaining < minRemaining {
			minRemaining = graphqlRemaining
		}

		if s.OdAdvanced.VaultApproleRoleId == "" {
			log.Printf("No VaultApproleRoleId, therefore will ALWAYS use the AccessToken supplied\n")
		} else {
			log.Printf("minRemaining : %d, minRemainingThresholdBeforeUsingAccessTokenAdditional : %d\n",
				minRemaining, minRemainingThresholdBeforeUsingAccessTokenAdditional)
			if minRemaining < minRemainingThresholdBeforeUsingAccessTokenAdditional {
				log.Printf("minRemaining is < minRemainingThresholdBeforeUsingAccessTokenAdditional ... therefore we will use the AccessTokenAdditional")
				log.Printf("Hey, this is an attempt to make concourse better so you won't get github rateLimiting issues ;)\n")
				log.Printf("setting AccessToken to first element in AccessTokenAdditional\n")
				// TODO altho we are passing a list of AccessTokenAdditional, we will only consider the first element as it is already sorted
				// by highest remaining ... in the future consider the rest of the list, altho this TODO is a low priority
				log.Printf("old AccessToken : %s_REDACTED\n", s.AccessToken[0:10])
				s.AccessToken, err = getAccessTokenFromVault(*s)
				if err != nil {
					log.Printf("There is a problem with vault %s\n", err)
					return nil, err
				}
				log.Printf("new AccessToken : %s_REDACTED\n", s.AccessToken[0:10])
				PrintCurrentRateLimit(*s)
			} else {
				log.Printf("there is sufficient minRemaining : %d rateLimit.  No need to use AccessTokenAdditional\n", minRemaining)
			}
		}
	}

	diskCachePath := filepath.Join(os.TempDir(), diskCacheFolder)
	cache := diskcache.New(diskCachePath)
	cachingTransport := httpcache.NewTransport(cache)

	// Skip SSL verification for self-signed certificates
	// source: https://github.com/google/go-github/pull/598#issuecomment-333039238
	if s.SkipSSLVerification {
		cachingTransport.Transport = &http.Transport{
			TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
		}
	}

	var ctx context.Context
	ctx = context.WithValue(context.TODO(), oauth2.HTTPClient, cachingTransport.Client())

	client := oauth2.NewClient(ctx, oauth2.StaticTokenSource(
		&oauth2.Token{AccessToken: s.AccessToken},
	))

	var v3 *github.Client
	if s.V3Endpoint != "" {
		endpoint, err := url.Parse(s.V3Endpoint)
		if err != nil {
			return nil, fmt.Errorf("failed to parse v3 endpoint: %s", err)
		}
		v3, err = github.NewEnterpriseClient(endpoint.String(), endpoint.String(), client)
		if err != nil {
			return nil, err
		}
	} else {
		v3 = github.NewClient(client)
	}

	var v4 *githubv4.Client
	if s.V4Endpoint != "" {
		endpoint, err := url.Parse(s.V4Endpoint)
		if err != nil {
			return nil, fmt.Errorf("failed to parse v4 endpoint: %s", err)
		}
		v4 = githubv4.NewEnterpriseClient(endpoint.String(), client)
		if err != nil {
			return nil, err
		}
	} else {
		v4 = githubv4.NewClient(client)
	}

	return &GithubClient{
		V3:         v3,
		V4:         v4,
		Owner:      owner,
		Repository: repository,
	}, nil
}

// sending metrics to datadog
func SendToDataDog(request GetRequest, err error) {
	s := request.Source
	if (s.OdAdvanced.DataDogApiKey != "") && (s.OdAdvanced.DataDogAppKey != "") {
		var status string = "success"
		if err != nil {
			if strings.Contains(err.Error(), "refusing to merge unrelated histories") {
				status = "refusingToMergeUnrelatedHistories"
			} else if strings.Contains(err.Error(), "does not exist") ||
				strings.Contains(err.Error(), "not accessible") {
				status = "doesNotExist"
			} else if strings.Contains(err.Error(), "Automatic merge failed; fix conflicts and then commit the result.") {
				status = "mergeConflict"
			} else {
				status = "unknown"
				log.Printf("TODO: map status : %s to a known status.  err.Error() : %s\n", status, err.Error())
			}
		}
		log.Printf("DataDogApiKey and DataDogAppKey were supplied\n")
		if s.OdAdvanced.DataDogMetricName == "" {
			s.OdAdvanced.DataDogMetricName = DefaultDataDogMetricName
		}
		if s.OdAdvanced.DataDogResourcesName == "" {
			s.OdAdvanced.DataDogResourcesName = DefaultDataDogResourcesName
		}
		if s.OdAdvanced.DataDogResourcesType == "" {
			s.OdAdvanced.DataDogResourcesType = DefaultDataDogResourcesType
		}
		log.Printf("DataDogMetricName : %s, DataDogResourcesName : %s, DataDogResourcesType : %s, status : %s\n",
			s.OdAdvanced.DataDogMetricName, s.OdAdvanced.DataDogResourcesName, s.OdAdvanced.DataDogResourcesType, status)
		// code borrowed from: https://docs.datadoghq.com/api/latest/metrics/?code-lang=go
		body := datadogV2.MetricPayload{
			Series: []datadogV2.MetricSeries{
				{
					Metric: s.OdAdvanced.DataDogMetricName,
					Type:   datadogV2.METRICINTAKETYPE_UNSPECIFIED.Ptr(),
					Points: []datadogV2.MetricPoint{
						{
							Timestamp: datadog.PtrInt64(time.Now().Unix()),
							Value:     datadog.PtrFloat64(1),
						},
					},
					Resources: []datadogV2.MetricResource{
						{
							Name: datadog.PtrString(s.OdAdvanced.DataDogResourcesName),
							Type: datadog.PtrString(s.OdAdvanced.DataDogResourcesType),
						},
						{
							Name: datadog.PtrString(status),
							Type: datadog.PtrString("status"),
						},
						{
							Name: datadog.PtrString(request.Version.PR),
							Type: datadog.PtrString("pr"),
						},
						{
							Name: datadog.PtrString(os.Getenv("BUILD_ID")),
							Type: datadog.PtrString("build_id"),
						},
						{
							Name: datadog.PtrString(os.Getenv("BUILD_NAME")),
							Type: datadog.PtrString("build_name"),
						},
						{
							Name: datadog.PtrString(os.Getenv("BUILD_PIPELINE_NAME")),
							Type: datadog.PtrString("build_pipeline_name"),
						},
					},
				},
			},
		}
		ctx := context.WithValue(
			context.Background(),
			datadog.ContextAPIKeys,
			map[string]datadog.APIKey{
				"apiKeyAuth": {
					Key: s.OdAdvanced.DataDogApiKey,
				},
				"appKeyAuth": {
					Key: s.OdAdvanced.DataDogAppKey,
				},
			},
		)
		configuration := datadog.NewConfiguration()
		apiClient := datadog.NewAPIClient(configuration)
		api := datadogV2.NewMetricsApi(apiClient)
		resp, r, err := api.SubmitMetrics(ctx, body, *datadogV2.NewSubmitMetricsOptionalParameters())
		log.Printf("Submitted metrics to DataDog\n")
		if err != nil {
			log.Printf("Error when calling MetricsApi.SubmitMetrics: %s\n", err)
			log.Printf("Full HTTP response: %v\n", r)
		}
		responseContent, _ := json.MarshalIndent(resp, "", "  ")
		log.Printf("Response from MetricsApi.SubmitMetrics:\n%s\n", responseContent)
	}
}

// ListPullRequests gets the last commit on all pull requests with the matching state.
func (m *GithubClient) ListPullRequests(prStates []githubv4.PullRequestState) ([]*PullRequest, error) {
	var query struct {
		Repository struct {
			PullRequests struct {
				Edges []struct {
					Node struct {
						PullRequestObject
						Reviews struct {
							TotalCount int
						} `graphql:"reviews(states: $prReviewStates)"`
						Commits struct {
							Edges []struct {
								Node struct {
									Commit CommitObject
								}
							}
						} `graphql:"commits(last:$commitsLast)"`
						Labels struct {
							Edges []struct {
								Node struct {
									LabelObject
								}
							}
						} `graphql:"labels(first:$labelsFirst)"`
					}
				}
				PageInfo struct {
					EndCursor   githubv4.String
					HasNextPage bool
				}
			} `graphql:"pullRequests(first:$prFirst,states:$prStates,after:$prCursor)"`
		} `graphql:"repository(owner:$repositoryOwner,name:$repositoryName)"`
	}

	vars := map[string]interface{}{
		"repositoryOwner": githubv4.String(m.Owner),
		"repositoryName":  githubv4.String(m.Repository),
		"prFirst":         githubv4.Int(100),
		"prStates":        prStates,
		"prCursor":        (*githubv4.String)(nil),
		"commitsLast":     githubv4.Int(1),
		"prReviewStates":  []githubv4.PullRequestReviewState{githubv4.PullRequestReviewStateApproved},
		"labelsFirst":     githubv4.Int(100),
	}

	var response []*PullRequest
	for {
		if err := m.V4.Query(context.TODO(), &query, vars); err != nil {
			return nil, err
		}
		for _, p := range query.Repository.PullRequests.Edges {
			labels := make([]LabelObject, len(p.Node.Labels.Edges))
			for _, l := range p.Node.Labels.Edges {
				labels = append(labels, l.Node.LabelObject)
			}

			for _, c := range p.Node.Commits.Edges {
				response = append(response, &PullRequest{
					PullRequestObject:   p.Node.PullRequestObject,
					Tip:                 c.Node.Commit,
					ApprovedReviewCount: p.Node.Reviews.TotalCount,
					Labels:              labels,
				})
			}
		}
		if !query.Repository.PullRequests.PageInfo.HasNextPage {
			break
		}
		vars["prCursor"] = query.Repository.PullRequests.PageInfo.EndCursor
	}
	return response, nil
}

// ListModifiedFiles in a pull request (not supported by V4 API).
func (m *GithubClient) ListModifiedFiles(prNumber int) ([]string, error) {
	var files []string

	opt := &github.ListOptions{
		PerPage: 100,
	}
	for {
		result, response, err := m.V3.PullRequests.ListFiles(
			context.TODO(),
			m.Owner,
			m.Repository,
			prNumber,
			opt,
		)
		if err != nil {
			return nil, err
		}
		for _, f := range result {
			files = append(files, *f.Filename)
		}
		if response.NextPage == 0 {
			break
		}
		opt.Page = response.NextPage
	}
	return files, nil
}

// PostComment to a pull request or issue.
func (m *GithubClient) PostComment(prNumber, comment string) error {
	pr, err := strconv.Atoi(prNumber)
	if err != nil {
		return fmt.Errorf("failed to convert pull request number to int: %s", err)
	}

	_, _, err = m.V3.Issues.CreateComment(
		context.TODO(),
		m.Owner,
		m.Repository,
		pr,
		&github.IssueComment{
			Body: github.String(comment),
		},
	)
	return err
}

// GetChangedFiles ...
func (m *GithubClient) GetChangedFiles(prNumber string, commitRef string) ([]ChangedFileObject, error) {
	pr, err := strconv.Atoi(prNumber)
	if err != nil {
		return nil, fmt.Errorf("failed to convert pull request number to int: %s", err)
	}

	var cfo []ChangedFileObject

	var filequery struct {
		Repository struct {
			PullRequest struct {
				Files struct {
					Edges []struct {
						Node struct {
							ChangedFileObject
						}
					} `graphql:"edges"`
					PageInfo struct {
						EndCursor   githubv4.String
						HasNextPage bool
					} `graphql:"pageInfo"`
				} `graphql:"files(first:$changedFilesFirst, after: $changedFilesEndCursor)"`
			} `graphql:"pullRequest(number:$prNumber)"`
		} `graphql:"repository(owner:$repositoryOwner,name:$repositoryName)"`
	}

	offset := ""

	for {
		vars := map[string]interface{}{
			"repositoryOwner":       githubv4.String(m.Owner),
			"repositoryName":        githubv4.String(m.Repository),
			"prNumber":              githubv4.Int(pr),
			"changedFilesFirst":     githubv4.Int(100),
			"changedFilesEndCursor": githubv4.String(offset),
		}

		if err := m.V4.Query(context.TODO(), &filequery, vars); err != nil {
			return nil, err
		}

		for _, f := range filequery.Repository.PullRequest.Files.Edges {
			cfo = append(cfo, ChangedFileObject{Path: f.Node.Path})
		}

		if !filequery.Repository.PullRequest.Files.PageInfo.HasNextPage {
			break
		}

		offset = string(filequery.Repository.PullRequest.Files.PageInfo.EndCursor)
	}

	return cfo, nil
}

func (m *GithubClient) getPullRequestHelper(prNumber, commitRef string, commitsLast int) (*PullRequest, error) {
	log.Printf("Performing getPullRequestHelper with on prNumber : %s, commitRef : %s, commitsLast : %d\n", prNumber, commitRef, commitsLast)
	if commitRef == "" {
		commitsLast = 1
	}
	pr, err := strconv.Atoi(prNumber)
	if err != nil {
		return nil, fmt.Errorf("failed to convert pull request number to int: %s", err)
	}

	var query struct {
		Repository struct {
			PullRequest struct {
				PullRequestObject
				Commits struct {
					Edges []struct {
						Node struct {
							Commit CommitObject
						}
					}
				} `graphql:"commits(last:$commitsLast)"`
			} `graphql:"pullRequest(number:$prNumber)"`
		} `graphql:"repository(owner:$repositoryOwner,name:$repositoryName)"`
	}

	vars := map[string]interface{}{
		"repositoryOwner": githubv4.String(m.Owner),
		"repositoryName":  githubv4.String(m.Repository),
		"prNumber":        githubv4.Int(pr),
		"commitsLast":     githubv4.Int(commitsLast),
	}

	// TODO: Pagination - in case someone pushes > 100 commits before the build has time to start :p
	if err := m.V4.Query(context.TODO(), &query, vars); err != nil {
		return nil, err
	}

	for _, c := range query.Repository.PullRequest.Commits.Edges {
		if commitRef == "" || c.Node.Commit.OID == commitRef {
			// Return as soon as we find the correct ref.
			return &PullRequest{
				PullRequestObject: query.Repository.PullRequest.PullRequestObject,
				Tip:               c.Node.Commit,
			}, nil
		}
	}

	// Return an error if the commit was not found
	return nil, fmt.Errorf("pr : %s, commit with ref '%s' does not exist ... with commitsLast : %d", prNumber, commitRef, commitsLast)
}

// GetPullRequest ...
func (m *GithubClient) GetPullRequest(prNumber, commitRef string) (*PullRequest, error) {
	commitsLast := 250 // seems to be a github limit
	pullRequest, err := m.getPullRequestHelper(prNumber, commitRef, commitsLast)
	if err != nil {
		log.Printf("Yikes, GetPullRequest with commitRef %s does not exist \n", commitRef)
		log.Printf("Perhaps a rebase on master on your feature branch could fix this\n")
	}
	return pullRequest, err
}

// UpdateCommitStatus for a given commit (not supported by V4 API).
func (m *GithubClient) UpdateCommitStatus(commitRef, baseContext, statusContext, status, targetURL, description string) error {
	if baseContext == "" {
		baseContext = "concourse-ci"
	}

	if statusContext == "" {
		statusContext = "status"
	}

	if targetURL == "" {
		targetURL = strings.Join([]string{os.Getenv("ATC_EXTERNAL_URL"), "builds", os.Getenv("BUILD_ID")}, "/")
	}

	if description == "" {
		description = fmt.Sprintf("Concourse CI build %s", status)
	}

	_, _, err := m.V3.Repositories.CreateStatus(
		context.TODO(),
		m.Owner,
		m.Repository,
		commitRef,
		&github.RepoStatus{
			State:       github.String(strings.ToLower(status)),
			TargetURL:   github.String(targetURL),
			Description: github.String(description),
			Context:     github.String(path.Join(baseContext, statusContext)),
		},
	)
	return err
}

func (m *GithubClient) DeletePreviousComments(prNumber string) error {
	pr, err := strconv.Atoi(prNumber)
	if err != nil {
		return fmt.Errorf("failed to convert pull request number to int: %s", err)
	}

	var getComments struct {
		Viewer struct {
			Login string
		}
		Repository struct {
			PullRequest struct {
				Id       string
				Comments struct {
					Edges []struct {
						Node struct {
							DatabaseId int64
							Author     struct {
								Login string
							}
						}
					}
				} `graphql:"comments(last:$commentsLast)"`
			} `graphql:"pullRequest(number:$prNumber)"`
		} `graphql:"repository(owner:$repositoryOwner,name:$repositoryName)"`
	}

	vars := map[string]interface{}{
		"repositoryOwner": githubv4.String(m.Owner),
		"repositoryName":  githubv4.String(m.Repository),
		"prNumber":        githubv4.Int(pr),
		"commentsLast":    githubv4.Int(100),
	}

	if err := m.V4.Query(context.TODO(), &getComments, vars); err != nil {
		return err
	}

	for _, e := range getComments.Repository.PullRequest.Comments.Edges {
		if e.Node.Author.Login == getComments.Viewer.Login {
			_, err := m.V3.Issues.DeleteComment(context.TODO(), m.Owner, m.Repository, e.Node.DatabaseId)
			if err != nil {
				return err
			}
		}
	}

	return nil
}

func parseRepository(s string) (string, string, error) {
	parts := strings.Split(s, "/")
	if len(parts) != 2 {
		return "", "", errors.New("malformed repository")
	}
	return parts[0], parts[1], nil
}

/*
returns rateLimit for core and rateLimit for graphql
i.e. github ratelimit has sections for different resources
*/
func getRateLimit(source Source) (int, int, error) {
	command := fmt.Sprintf("curl -s https://api.github.com/rate_limit -H \"Authorization: token %s\" > rateLimit.json", source.AccessToken)
	_, err := exec.Command("sh", "-c", command).Output()
	if err != nil {
		return 0, 0, fmt.Errorf("getRateLimit curl error : %s", err)
	}
	command = fmt.Sprintf("cat rateLimit.json | jq -r '.resources.core.remaining'")
	coreRemaining, err := exec.Command("sh", "-c", command).Output()
	if err != nil {
		return 0, 0, fmt.Errorf("getRateLimit jq error : %s", err)
	}
	coreRemainingInt, _ := strconv.Atoi(strings.TrimSpace(fmt.Sprintf("%s", coreRemaining)))
	command = fmt.Sprintf("cat rateLimit.json | jq -r '.resources.graphql.remaining'")
	graphqlRemaining, err := exec.Command("sh", "-c", command).Output()
	if err != nil {
		return 0, 0, fmt.Errorf("getRateLimit jq error : %s", err)
	}
	graphqlRemainingInt, _ := strconv.Atoi(strings.TrimSpace(fmt.Sprintf("%s", graphqlRemaining)))
	return coreRemainingInt, graphqlRemainingInt, nil
}

func PrintCurrentRateLimit(source Source) {
	coreRemaining, graphqlRemaining, err := getRateLimit(source)
	if err == nil {
		log.Printf("Github rateLimit coreRemaining : %d, graphqlRemaining : %d\n", coreRemaining, graphqlRemaining)
	} else {
		log.Printf("err is %s\n", err)
	}
}

func getAccessTokenFromVault(source Source) (string, error) {
	log.Printf("Retrieving latest github-token (github app) using vault\n")
	config := vault.DefaultConfig() // modify for more granular configuration
	config.Address = source.OdAdvanced.VaultAddr
	client, err := vault.NewClient(config)
	if err != nil {
		return "", fmt.Errorf("unable to initialize Vault client: %w", err)
	}
	roleID := source.OdAdvanced.VaultApproleRoleId
	secretID := &auth.SecretID{FromString: source.OdAdvanced.VaultApproleSecretId}
	appRoleAuth, err := auth.NewAppRoleAuth(
		roleID,
		secretID,
	)
	if err != nil {
		return "", fmt.Errorf("unable to initialize AppRole auth method: %w", err)
	}
	authInfo, err := client.Auth().Login(context.Background(), appRoleAuth)
	if err != nil {
		return "", fmt.Errorf("unable to login to AppRole auth method: %w", err)
	}
	if authInfo == nil {
		return "", fmt.Errorf("no auth info was returned after login")
	}
	// hmm client.KVv2() doesn't work, so we'll use v1 of client.Logical()
	// p.s. and this is exactly why you need to install the go debugger ... frigging hell to debug without it
	secret, err := client.Logical().Read("concourse/engineering/github-token-from-app-1")
	if err != nil {
		return "", fmt.Errorf("unable to read secret: %w", err)
	}
	// data map can contain more than one key-value pair,
	// in this case we're just grabbing one of them
	value, ok := secret.Data["value"].(string)
	if !ok {
		return "", fmt.Errorf("cannot retrieve vault value")
	}
	return value, nil
}
