package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"strconv"
	"time"

	resource "github.com/telia-oss/github-pr-resource"
)

func main() {
	var request resource.GetRequest
	var decoder *json.Decoder
	var outputDir string
	var localDevelopmentBool = false
	localDevelopment, localDevelopmentPresent := os.LookupEnv("LOCAL_DEVELOPMENT")
	if localDevelopmentPresent {
		localDevelopmentBool, _ = strconv.ParseBool(localDevelopment)
	}
	if localDevelopmentBool {
		// local development (yippee!  Fire up that debugger)
		reader, _ := os.Open(os.Getenv("REQUEST_JSON"))
		decoder = json.NewDecoder(reader)
		outputDirPrefix := os.Getenv("OUTPUT_DIR_PREFIX")
		now := time.Now()
		outputDir = outputDirPrefix + "/" + fmt.Sprintf("%d", now.UnixMilli())
		os.Mkdir(outputDir, 0777)
	} else {
		// business as usual with original production code logic
		decoder = json.NewDecoder(os.Stdin)
		outputDir = os.Args[1]
	}
	decoder.DisallowUnknownFields()

	if err := decoder.Decode(&request); err != nil {
		log.Fatalf("failed to unmarshal request: %s", err)
	}
	resource.PrintDebugInput(request.Source, request)
	if len(os.Args) < 2 && !localDevelopmentBool {
		log.Fatalf("missing arguments")
	}

	if err := request.Source.Validate(); err != nil {
		log.Fatalf("invalid source configuration: %s", err)
	}
	git, err := resource.NewGitClient(&request.Source, outputDir, os.Stderr)
	if err != nil {
		log.Fatalf("failed to create git client: %s", err)
	}
	github, err := resource.NewGithubClient(&request.Source)
	if err != nil {
		log.Fatalf("failed to create github manager: %s", err)
	}
	response, err := resource.Get(request, github, git, outputDir)
	resource.SendToDataDog(request, err)
	if err != nil {
		log.Fatalf("get failed: %s", err)
	}
	resource.PrintCurrentRateLimit(request.Source)
	resource.PrintDebugOutput(request.Source, response)
	if err := json.NewEncoder(os.Stdout).Encode(response); err != nil {
		log.Fatalf("failed to marshal response: %s", err)
	}
	resource.SayThanks()
}
