FROM golang:alpine as clash_builder

RUN apk add --no-cache make git && \
    wget -O /Country.mmdb https://github.com/Dreamacro/maxmind-geoip/releases/latest/download/Country.mmdb
WORKDIR /clash-src
COPY --from=tonistiigi/xx:golang / /
ADD https://api.github.com/repos/Dreamacro/clash/git/refs/heads/master /clash-version.json
RUN git clone --depth 1 https://github.com/Dreamacro/clash.git .
RUN go env -w GOPROXY=https://goproxy.cn,direct
RUN go mod download && \
    make docker && \
    mv ./bin/clash-docker /clash

FROM alpine:latest

RUN apk --no-cache add ca-certificates
COPY --from=clash_builder /Country.mmdb /root/.config/clash/
COPY --from=clash_builder /clash /
ENTRYPOINT ["/clash"]