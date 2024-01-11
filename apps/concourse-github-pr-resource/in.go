package resource

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
)

type GetError struct {
	Context string
	Err     error
}

func (getError *GetError) Error() string {
	return fmt.Sprintf("%s: %v", getError.Context, getError.Err)
}

func Wrap(err error, info string) *GetError {
	return &GetError{
		Context: info,
		Err:     err,
	}
}

// Get (business logic)
func Get(request GetRequest, github Github, git Git, outputDir string) (*GetResponse, error) {
	if request.Params.GitDepth == 0 {
		request.Params.GitDepth = DefaultGitDepth
	}
	if request.Params.SkipDownload {
		return &GetResponse{Version: request.Version}, nil
	}
	log.Printf("outputDir %s\n", outputDir)
	pull, err := github.GetPullRequest(request.Version.PR, request.Version.Commit)
	if err != nil {
		return nil, fmt.Errorf("failed to retrieve pull request: %s", err)
	}
	log.Printf("Pull request number : %d, commit : %s\n", pull.Number, request.Version.Commit)

	// Initialize and pull the base for the PR
	if err := git.Init(pull.BaseRefName); err != nil {
		return nil, err
	}
	if err := git.Pull(pull.Repository.URL, pull.BaseRefName, request.Params.GitDepth, request.Params.Submodules, request.Params.FetchTags); err != nil {
		return nil, err
	}

	// Get the last commit SHA in base for the metadata
	baseSHA, err := git.RevParse(pull.BaseRefName)
	if err != nil {
		return nil, err
	}

	// Fetch the PR and merge the specified commit into the base
	if err := git.Fetch(pull.Repository.URL, pull.Number, request.Params.GitDepth, request.Params.Submodules); err != nil {
		return nil, err
	}

	// Create the metadata
	var metadata Metadata
	metadata.Add("pr", strconv.Itoa(pull.Number))
	metadata.Add("title", pull.Title)
	metadata.Add("url", pull.URL)
	metadata.Add("head_name", pull.HeadRefName)
	metadata.Add("head_sha", pull.Tip.OID)
	metadata.Add("base_name", pull.BaseRefName)
	metadata.Add("base_sha", baseSHA)
	metadata.Add("message", pull.Tip.Message)
	metadata.Add("author", pull.Tip.Author.User.Login)
	metadata.Add("author_email", pull.Tip.Author.Email)
	metadata.Add("state", string(pull.State))

	// Write version and metadata for reuse in PUT
	path := filepath.Join(outputDir, ".git", "resource")
	if err := os.MkdirAll(path, os.ModePerm); err != nil {
		return nil, fmt.Errorf("failed to create output directory: %s", err)
	}
	b, err := json.Marshal(request.Version)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal version: %s", err)
	}
	if err := ioutil.WriteFile(filepath.Join(path, "version.json"), b, 0644); err != nil {
		return nil, fmt.Errorf("failed to write version: %s", err)
	}
	b, err = json.Marshal(metadata)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal metadata: %s", err)
	}
	if err := ioutil.WriteFile(filepath.Join(path, "metadata.json"), b, 0644); err != nil {
		return nil, fmt.Errorf("failed to write metadata: %s", err)
	}

	for _, d := range metadata {
		filename := d.Name
		content := []byte(d.Value)
		if err := ioutil.WriteFile(filepath.Join(path, filename), content, 0644); err != nil {
			return nil, fmt.Errorf("failed to write metadata file %s: %s", filename, err)
		}
	}

	switch tool := request.Params.IntegrationTool; tool {
	case "rebase":
		if err := git.Rebase(pull.BaseRefName, pull.Tip.OID, request.Params.Submodules); err != nil {
			return nil, err
		}
	case "merge", "":
		log.Printf("BEGIN merge")
		var command, outTrim string
		var out []byte
		var cmdErr error
		var useLatestPRCommit bool
		for {
			err = git.Merge(pull.Tip.OID, request.Params.Submodules)
			if err == nil {
				log.Printf("Sweet ... no errors with merge after depth of %d\n", request.Params.GitDepth)
				break
			} else if request.Params.GitDepth >= MaxGitDepth {
				break
			} else if strings.Contains(err.Error(), "Automatic merge failed; fix conflicts and then commit the result.") {
				log.Printf("Exiting early because we have a git conflict %s\n", err.Error())
				break
			} else {
				log.Printf("Error : %s with Merge %s on depth : %d\n", err, pull.Tip.OID, request.Params.GitDepth)
				log.Printf("Performing merge abort ...")
				command = fmt.Sprintf("cd %s && git merge --abort 2>&1", outputDir)
				out, _ = exec.Command("sh", "-c", command).CombinedOutput()
				outTrim = strings.TrimSpace(string(out))
				log.Printf("command : %s returned: %s\n", command, outTrim)

				request.Params.GitDepth *= 2
				log.Printf("deepening fetch to reach pullNumber : %d with depth : %d\n", pull.Number, request.Params.GitDepth)

				if !useLatestPRCommit {
					useLatestPRCommit = true
					// get last pr commit
					pull, _ := github.GetPullRequest(request.Version.PR, request.Version.Commit)
					log.Printf("using last pr commit : %s, CommittedDate : %s\n", pull.Tip.OID, pull.Tip.CommittedDate)
					request.Version.Commit = pull.Tip.OID
				}

				// pull branch
				// note calling git.Pull(pull.Repository.URL, pull.BaseRefName, request.Params.GitDepth, request.Params.Submodules, request.Params.FetchTags)
				// again won't work as that calls git remote add ...
				// honestly, although most of this resourceType is written in Go ... underneath it uses exec ... which begs the question
				// shouldn't this have been written in Bash?
				command = fmt.Sprintf("cd %s && git pull --depth %d origin %s", outputDir, request.Params.GitDepth, pull.BaseRefName)
				out, cmdErr = exec.Command("sh", "-c", command).CombinedOutput()
				outTrim = strings.TrimSpace(string(out))
				log.Printf("command : %s returned: %s\n", command, outTrim)
				if cmdErr != nil {
					log.Printf("commandErr : %s", cmdErr)
				}

				// fetch pull
				command = getFetchCommand(git, outputDir, pull.Number, request.Params.GitDepth, false)
				commandRedacted := getFetchCommand(git, outputDir, pull.Number, request.Params.GitDepth, true)
				out, cmdErr = exec.Command("sh", "-c", command).CombinedOutput()
				outTrim = strings.TrimSpace(string(out))
				if cmdErr != nil {
					log.Printf("commandErr : %s, command : %s\n", cmdErr, commandRedacted)
				}
				log.Printf("command : %s returned: %s\n", commandRedacted, outTrim)
				log.Printf("==================================================================================\n")
			}
		}
		log.Printf("END merge")
		if err != nil {
			log.Printf("merge failed after depth of %d (maxDepth : %d), returning err %s\n", request.Params.GitDepth, MaxGitDepth, err)
			err = Wrap(err, outTrim+errBuffer.String())
			return nil, err
		}
	case "checkout":
		if err := git.Checkout(pull.HeadRefName, pull.Tip.OID, request.Params.Submodules); err != nil {
			return nil, err
		}
	default:
		return nil, fmt.Errorf("invalid integration tool specified: %s", tool)
	}

	if request.Source.GitCryptKey != "" {
		if err := git.GitCryptUnlock(request.Source.GitCryptKey); err != nil {
			return nil, err
		}
	}

	if request.Params.ListChangedFiles {
		cfol, err := github.GetChangedFiles(request.Version.PR, request.Version.Commit)
		if err != nil {
			return nil, fmt.Errorf("failed to fetch list of changed files: %s", err)
		}

		var fl []byte

		for _, v := range cfol {
			fl = append(fl, []byte(v.Path+"\n")...)
		}

		// Create List with changed files
		if err := ioutil.WriteFile(filepath.Join(path, "changed_files"), fl, 0644); err != nil {
			return nil, fmt.Errorf("failed to write file list: %s", err)
		}
	}

	return &GetResponse{
		Version:  request.Version,
		Metadata: metadata,
	}, nil
}

func getFetchCommand(git Git, buildDir string, pullNumber int, gitDepth int, redacted bool) string {
	var gitOrigin string
	if redacted {
		gitOrigin = "https://redacted"
	} else {
		originCommand := fmt.Sprintf("cd %s && git ls-remote --get-url origin", buildDir)
		out, _ := exec.Command("sh", "-c", originCommand).CombinedOutput()
		gitOrigin = strings.TrimSpace(string(out))
	}
	return fmt.Sprintf("cd %s && git fetch %s pull/%d/head --depth %d 2>&1", buildDir, gitOrigin, pullNumber, gitDepth)
}

// GetParameters ...
type GetParameters struct {
	SkipDownload     bool   `json:"skip_download"`
	IntegrationTool  string `json:"integration_tool"`
	GitDepth         int    `json:"git_depth"`
	Submodules       bool   `json:"submodules"`
	ListChangedFiles bool   `json:"list_changed_files"`
	FetchTags        bool   `json:"fetch_tags"`
}

// GetRequest ...
type GetRequest struct {
	Source  Source        `json:"source"`
	Version Version       `json:"version"`
	Params  GetParameters `json:"params"`
}

// GetResponse ...
type GetResponse struct {
	Version  Version  `json:"version"`
	Metadata Metadata `json:"metadata,omitempty"`
}
