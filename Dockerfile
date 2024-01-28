FROM golang:1.19-alpine AS builder
ENV CGO_ENABLED=0
WORKDIR /backend
COPY backend/go.* .
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go mod download
COPY backend/. .
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go build -trimpath -ldflags="-s -w" -o bin/service

FROM --platform=$BUILDPLATFORM node:18.12-alpine3.16 AS client-builder
WORKDIR /ui
# cache packages in layer
COPY ui/package.json /ui/package.json
COPY ui/package-lock.json /ui/package-lock.json
RUN --mount=type=cache,target=/usr/src/app/.npm \
    npm set cache /usr/src/app/.npm && \
    npm ci
# install
COPY ui /ui
RUN npm run build

FROM alpine
LABEL org.opencontainers.image.title="HoppscotchExtension" \
    org.opencontainers.image.description="Hoppscotch Extension" \
    org.opencontainers.image.vendor="MaRTiN" \
    com.docker.desktop.extension.api.version="0.3.4" \
    com.docker.extension.screenshots="[{\"alt\": \"hoppscotch\",\"url\":\"https://addons.mozilla.org/user-media/previews/full/266/266192.png\"}]"\
    com.docker.desktop.extension.icon="" \
    com.docker.extension.detailed-description="Docker Extension for Hoppscotch" \
    com.docker.extension.publisher-url="" \
    com.docker.extension.additional-urls="" \
    com.docker.extension.categories="" \
    com.docker.extension.changelog=""

COPY docker-compose.yaml .
COPY metadata.json .
COPY hoppscotch.svg .
COPY ui ui
