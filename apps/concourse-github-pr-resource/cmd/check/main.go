package main

import (
	"encoding/json"
	"log"
	"os"
	"strconv"

	resource "github.com/telia-oss/github-pr-resource"
)

func main() {
	var request resource.CheckRequest
	var decoder *json.Decoder
	var localDevelopmentBool = false
	localDevelopment, localDevelopmentPresent := os.LookupEnv("LOCAL_DEVELOPMENT")
	if localDevelopmentPresent {
		localDevelopmentBool, _ = strconv.ParseBool(localDevelopment)
	}
	if localDevelopmentBool {
		// local development (yippee!  Fire up that debugger)
		reader, _ := os.Open(os.Getenv("REQUEST_JSON"))
		decoder = json.NewDecoder(reader)
	} else {
		// business as usual with original production code logic
		decoder = json.NewDecoder(os.Stdin)
	}
	decoder.DisallowUnknownFields()
	if err := decoder.Decode(&request); err != nil {
		log.Fatalf("failed to unmarshal request: %s", err)
	}
	resource.PrintDebugInput(request.Source, request)
	if err := request.Source.Validate(); err != nil {
		log.Fatalf("invalid source configuration: %s", err)
	}
	github, err := resource.NewGithubClient(&request.Source)
	if err != nil {
		log.Fatalf("failed to create github manager: %s", err)
	}
	response, err := resource.Check(request, github)
	if err != nil {
		log.Fatalf("check failed: %s", err)
	}
	resource.PrintCurrentRateLimit(request.Source)
	resource.PrintDebugOutput(request.Source, response)
	if err := json.NewEncoder(os.Stdout).Encode(response); err != nil {
		log.Fatalf("failed to marshal response: %s", err)
	}
	resource.SayThanks()
}
