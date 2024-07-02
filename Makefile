GOOS := $(shell go env GOOS)
GOARCH := $(shell go env GOARCH)

ifeq ($(GOOS),darwin)
	ifeq ($(GOARCH),amd64)
		OUTPUT := bin_darwin_x86_64.dylib
	else ifeq ($(GOARCH),arm64)
		OUTPUT := bin_darwin_arm64.dylib
	else
		OUTPUT := bin_darwin_$(GOARCH).dylib
	endif
else ifeq ($(GOOS),windows)
	ifeq ($(GOARCH),amd64)
		OUTPUT := bin_windows_x86_64.dll
	else ifeq ($(GOARCH),arm64)
		OUTPUT := bin_windows_arm64.dll
	else
		OUTPUT := bin_windows_$(GOARCH).dll
	endif
else
	ifeq ($(GOARCH),amd64)
		OUTPUT := bin_linux_x86_64.so
	else ifeq ($(GOARCH),arm64)
		OUTPUT := bin_linux_arm64.so
	else
		OUTPUT := bin_linux_$(GOARCH).so
	endif
endif

build:
	mkdir -p bin
	CGO_ENABLED=1 go build -buildmode=c-shared -o ./bin/$(OUTPUT) main.go

.PHONY: build