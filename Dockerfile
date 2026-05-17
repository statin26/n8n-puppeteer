FROM n8nio/n8n:latest

USER root

# Install Chromium and required dependencies
RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ttf-freefont \
    ghostscript \
    bash \
    && rm -rf /var/cache/apk/*

# Install Puppeteer
RUN npm install -g puppeteer --unsafe-perm=true

# Install n8n Puppeteer community node
RUN npm install -g n8n-nodes-puppeteer \
    --unsafe-perm=true \
    --legacy-peer-deps

# Puppeteer environment
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Switch back to non-root user
USER node
