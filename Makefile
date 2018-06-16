.PHONY: all test clean fast release install

GO15VENDOREXPERIMENT=1

PROG_NAME := "gox"

REPO_URI := github.com/sniperkit/gox

COMMIT_ID   ?= $(shell git describe --tags --always --dirty=-dev)
COMMIT_UNIX ?= $(shell git show -s --format=%ct HEAD)

BUILD_COUNT ?= $(shell git rev-list --count HEAD)
BUILD_UNIX  ?= $(shell date +%s)
BUILD_VERSION := $(shell cat $(CURDIR)/VERSION)
BUILD_TIME := $(shell date)

BUILD_LDFLAGS = \
	-X '$(REPO_URI)/pkg.CommitID=$(COMMIT_ID)' \
	-X '$(REPO_URI)/pkg.CommitUnix=$(COMMIT_UNIX)' \
	-X '$(REPO_URI)/pkg.BuildVersion=$(BUILD_VERSION)' \
	-X '$(REPO_URI)/pkg.BuildCount=$(BUILD_COUNT)' \
	-X '$(REPO_URI)/pkg.BuildUnix=$(BUILD_UNIX)' \
	-X '$(REPO_URI)/pkg.BuildTime=$(BUILD_TIME)'

all: test build example install version


build:
	@go build -ldflags "$(BUILD_LDFLAGS)" -tags cli -o ./bin/$(PROG_NAME) ./cmd/$(PROG_NAME)/*.go
	@./bin/$(PROG_NAME) --version	

version:
	@which $(PROG_NAME)
	@$(PROG_NAME) --version

install: deps
	@go install -ldflags "$(BUILD_LDFLAGS)" -tags cli ./cmd/$(PROG_NAME)
	@$(PROG_NAME) --version

fast: deps
	@go build -i -ldflags "$(BUILD_LDFLAGS)" -o ./bin/$(PROG_NAME) -tags cli ./cmd/$(PROG_NAME)/*.go
	@$(PROG_NAME) --version

deps:
	@glide install --strip-vendor

deps-ci:
	@go get -v -u github.com/go-playground/overalls
	@go get -v -u github.com/mattn/goveralls
	@go get -v -u golang.org/x/tools/cmd/cover

test:
	@go test ./pkg/...

clean:
	@go clean
	@rm -fr ./bin
	@rm -fr ./dist

release: $(PROG_NAME)
	@git tag -a `cat VERSION`
	@git push origin `cat VERSION`

