# Dotfiles Makefile

.PHONY: all install build build-all test test-unit clean help

# Default target
all: help

# Build Go installer for current platform
build:
	@echo "Building dotfiles installer..."
	@mkdir -p bin
	@cd cmd/dotfiles && go build -o ../../bin/dotfiles .
	@echo "Binary created at bin/dotfiles"

# Build for all platforms (used in CI)
build-all:
	@echo "Building for all platforms..."
	@mkdir -p bin
	@cd cmd/dotfiles && GOOS=darwin GOARCH=amd64 go build -o ../../bin/dotfiles-darwin-amd64 .
	@cd cmd/dotfiles && GOOS=darwin GOARCH=arm64 go build -o ../../bin/dotfiles-darwin-arm64 .
	@cd cmd/dotfiles && GOOS=linux GOARCH=amd64 go build -o ../../bin/dotfiles-linux-amd64 .
	@cd cmd/dotfiles && GOOS=linux GOARCH=arm64 go build -o ../../bin/dotfiles-linux-arm64 .
	@echo "Binaries created in bin/"

# Install dotfiles (build and run)
install: build
	@./bin/dotfiles

# Install with dry-run (preview changes)
install-dry-run: build
	@./bin/dotfiles -dry-run

# Run integration tests in Docker
test:
	@echo "Running integration tests in Docker..."
	@docker build -t dotfiles-test -f test/Dockerfile .
	@docker run --rm dotfiles-test

# Run Go unit tests (dry-run test only, no integration)
test-unit:
	@cd cmd/dotfiles && go test -v ./...

# Clean build artifacts
clean:
	@rm -rf bin/
	@docker rmi dotfiles-test 2>/dev/null || true
	@echo "Cleaned build artifacts"

# Help
help:
	@echo "Dotfiles Installation"
	@echo ""
	@echo "Usage:"
	@echo "  make install         Build and install dotfiles"
	@echo "  make install-dry-run Preview changes without making them"
	@echo "  make build           Build binary for current platform"
	@echo "  make build-all       Build binaries for all platforms"
	@echo "  make test            Run integration tests in Docker"
	@echo "  make test-unit       Run unit tests locally"
	@echo "  make clean           Remove build artifacts"
