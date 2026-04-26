package main

import (
	"github.com/stefanhoglund/D7024E/internal/cli"
	"github.com/stefanhoglund/D7024E/pkg/build"
)

var (
	BuildVersion string = ""
	BuildTime    string = ""
)

func main() {
	build.BuildVersion = BuildVersion
	build.BuildTime = BuildTime
	cli.Execute()
}
