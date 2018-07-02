
FROM cirepo/nix:2.0.4_bionic

MAINTAINER haolun

COPY --from=tmp/dumper:latest /data/root /data/root
