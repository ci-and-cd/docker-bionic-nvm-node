
FROM ubuntu:18.04

COPY --from=tmp/dumper:latest /data/root /data/root
