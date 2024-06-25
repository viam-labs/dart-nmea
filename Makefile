# Makefile

# Define the output directory
BIN_DIR := bin

# Define targets
TARGETS := linux-amd64 linux-arm64 windows-amd64 darwin-amd64 darwin-arm64 ios

# Main build rule
build: $(BIN_DIR) $(TARGETS)

# Create bin directory
$(BIN_DIR):
	mkdir -p $(BIN_DIR)

# Rules for each target
linux-amd64:
	CC=x86_64-linux-musl-gcc GOOS=linux GOARCH=amd64 CGO_ENABLED=1 \
	go build -buildmode=c-shared -o $(BIN_DIR)/bin_linux_x86_64.so main.go

linux-arm64:
	CC=aarch64-linux-musl-gcc GOOS=linux GOARCH=arm64 CGO_ENABLED=1 \
	go build -buildmode=c-shared -o $(BIN_DIR)/bin_linux_arm64.so main.go

windows-amd64:
	CC=x86_64-w64-mingw32-gcc GOOS=windows GOARCH=amd64 CGO_ENABLED=1 \
	go build -buildmode=c-shared -o $(BIN_DIR)/bin_windows_x86_64.dll main.go

darwin-amd64:
	GOOS=darwin GOARCH=amd64 CGO_ENABLED=1 \
	go build -buildmode=c-shared -o $(BIN_DIR)/bin_darwin_x86_64.dylib main.go

darwin-arm64:
	GOOS=darwin GOARCH=arm64 CGO_ENABLED=1 \
	go build -buildmode=c-shared -o $(BIN_DIR)/bin_darwin_arm64.dylib main.go

ios:
	GOOS=ios GOARCH=arm64 SDK=iphoneos CGO_ENABLED=1 CGO_CFLAGS="-fembed-bitcode" \
	go build -buildmode=c-archive -o $(BIN_DIR)/bin_ios_arm64.a main.go

# Clean rule
clean:
	rm -rf $(BIN_DIR)

.PHONY: build clean $(TARGETS)