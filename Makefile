OUTPUT := bin_$(shell go env GOOS)_$(shell go env GOARCH)$(shell go env GOEXE)

ifeq ($(GOOS), windows)
EXT := dll
else ifeq ($(GOOS), darwin)
EXT := dylib
else
EXT := so
endif

build:
	mkdir -p bin
	CGO_ENABLED=1 go build -buildmode=c-shared -o ./bin/$(OUTPUT).$(EXT) main.go

.PHONY: build