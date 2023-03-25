
docker run --name 389ds-alpine --rm -p 3389:3389 -p 3636:3636 \
  -v `pwd`/data:/data ghcr.io/thorsten-l/389ds-alpine:latest
