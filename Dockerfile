FROM golang:1.24-bookworm AS builder

RUN apt-get update -y && apt-get install -y ca-certificates fuse3 sqlite3

WORKDIR /usr/src/app
COPY go.mod go.sum ./
RUN go mod download && go mod verify
COPY . .
RUN go build -v -o /run-app .

FROM debian:bookworm
ARG LITEFS_CONFIG=litefs.yml

# Copy binaries from the previous build stages.
COPY --from=flyio/litefs:0.5 /usr/local/bin/litefs /usr/local/bin/litefs
COPY --from=builder /run-app /usr/local/bin/go-example

# Copy the possible LiteFS configurations.
ADD flyio/litefs.yml /tmp/litefs.yml
ADD flyio/litefs.static-lease.yml /tmp/litefs.static-lease.yml

# Move the appropriate LiteFS config file to /etc/ (this one will be
# used by LiteFS). By default this is the config file used on Fly.io,
# but it's set appropriately to other files for the docker setup in
# docker-compose.yml
RUN cp /tmp/$LITEFS_CONFIG /etc/litefs.yml

# Install required libs
RUN apt-get update -y && apt-get install -y ca-certificates fuse3 sqlite3

# Run LiteFS as the entrypoint. After it has connected and sync'd with the
# cluster, it will run the commands listed in the "exec" field of the config.
ENTRYPOINT litefs mount