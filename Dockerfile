FROM n8nio/n8n:latest

USER root

RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    bash

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

RUN npm install -g puppeteer

RUN npm install -g n8n-nodes-puppeteer --unsafe-perm=true --legacy-peer-deps

RUN adduser -D -s /bin/bash n8nuser

USER n8nuser
