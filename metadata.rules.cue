#Spec: {
	app:  #NonEmptyString
	base: bool
	channels: [...#Channels]
}

#Channels: {
	name: #NonEmptyString
	platforms: [...#AcceptedPlatforms]
	stable: bool
	// Stable channels of one app share a package, so only one of them may own
	// the floating `:rolling` tag. Required when an app has more than one
	// stable channel; implicit (and unnecessary) when it has exactly one.
	rolling?: bool
	tests: {
		enabled: bool
		type?:   =~"^(cli|web)$"
	}
}

#NonEmptyString:           string & !=""
#AcceptedPlatforms:        "linux/amd64" | "linux/arm64"
