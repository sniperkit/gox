package main

import (
	"os"

	"github.com/sniperkit/gox/pkg"
)

func main() {
	// Call MainCLI so that defers work properly, since os.Exit won't call defers.
	os.Exit(gox.MainCLI())
}
