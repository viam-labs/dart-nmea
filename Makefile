OUTPUT := bin_$(shell go env GOOS)_$(shell go env GOARCH)$(shell go env GOEXE) | sed 's|\.||g'

build:
	mkdir -p bin
	CGO_ENABLED=1 go build -buildmode=c-shared -o ./bin/$(OUTPUT) main.go

.PHONY: build