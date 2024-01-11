package main

import (
	"encoding/json"
	"log"
	"os"

	resource "github.com/telia-oss/github-pr-resource"
)

func main() {
	var request resource.PutRequest

	decoder := json.NewDecoder(os.Stdin)
	decoder.DisallowUnknownFields()

	if err := decoder.Decode(&request); err != nil {
		log.Fatalf("failed to unmarshal request: %s", err)
	}
	resource.PrintDebugInput(request.Source, request)
	if len(os.Args) < 2 {
		log.Fatalf("missing arguments")
	}
	sourceDir := os.Args[1]
	if err := request.Source.Validate(); err != nil {
		log.Fatalf("invalid source configuration: %s", err)
	}
	github, err := resource.NewGithubClient(&request.Source)
	if err != nil {
		log.Fatalf("failed to create github manager: %s", err)
	}
	response, err := resource.Put(request, github, sourceDir)
	if err != nil {
		log.Fatalf("put failed: %s", err)
	}
	resource.PrintCurrentRateLimit(request.Source)
	resource.PrintDebugOutput(request.Source, response)
	if err := json.NewEncoder(os.Stdout).Encode(response); err != nil {
		log.Fatalf("failed to marshal response: %s", err)
	}
	resource.SayThanks()
}
