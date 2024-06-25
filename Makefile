GOOS := $(shell go env GOOS)
GOARCH := $(shell go env GOARCH)

ifeq ($(GOOS),darwin)
	OUTPUT := ../bin/bin.dylib
else ifeq ($(GOOS),windows)
	OUTPUT := ../bin/bin.dll
else
	OUTPUT := ../bin/bin.so
endif

build:
	go build -buildmode=c-shared -o $(OUTPUT) main.go

.PHONY: build