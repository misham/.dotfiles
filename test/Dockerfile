# Dockerfile for testing dotfiles installation

FROM golang:1.21-bookworm

# Install dependencies
RUN apt-get update && apt-get install -y \
    bash \
    git \
    vim \
    curl \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create test user
RUN useradd -m -s /bin/bash testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER testuser

# Copy dotfiles
COPY --chown=testuser:testuser . /home/testuser/.dotfiles

ENV HOME=/home/testuser
ENV INTEGRATION_TEST=1

# Run integration tests from the Go module directory
WORKDIR /home/testuser/.dotfiles/cmd/dotfiles
CMD ["go", "test", "-v", "./..."]
