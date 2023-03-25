docker run --name 389ds-base --rm \
  -v `pwd`/data:/data -it 389ds:base-alpine /bin/bash
