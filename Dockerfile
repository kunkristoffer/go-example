FROM golang:1.24-bookworm AS builder

RUN apt-get update -y && apt-get install -y ca-certificates sqlite3

WORKDIR /usr/src/app

COPY go.mod go.sum ./
RUN go mod download && go mod verify

COPY . .
RUN go build -o /usr/local/bin/chat-app .

# Download the static build of Litestream directly into the path & make it executable.
# This is done in the builder and copied as the chmod doubles the size.
ADD https://github.com/benbjohnson/litestream/releases/download/v0.3.13/litestream-v0.3.13-linux-amd64.tar.gz /tmp/litestream.tar.gz
RUN tar -C /usr/local/bin -xzf /tmp/litestream.tar.gz

FROM debian:bookworm

# Copy binaries from the previous build stages.
COPY --from=builder /usr/local/bin/chat-app /usr/local/bin/chat-app
COPY --from=builder /usr/local/bin/litestream /usr/local/bin/litestream

# Install required libs
RUN apt-get update -y && apt-get install -y ca-certificates sqlite3

# Create data directory (although this will likely be mounted too)
RUN mkdir -p /database

# Notify Docker that the container wants to expose a port.
EXPOSE 8080

# Copy Litestream configuration file & startup script.
COPY etc/litestream.yml /etc/litestream.yml
COPY scripts/replication.sh /scripts/replication.sh

# CMD [ "tail", "-f", "/dev/null" ]
CMD [ "/scripts/replication.sh" ]