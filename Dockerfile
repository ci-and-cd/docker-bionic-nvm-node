
FROM alpine:3.7

MAINTAINER haolun

COPY --from=tmp/dumper:latest /data/root /data/root
