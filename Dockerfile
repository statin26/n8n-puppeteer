# Step 1: Use a standard Alpine image to safely grab apk and download Chromium
FROM alpine:3.20 AS alpine-builder
RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ttf-freefont \
    ghostscript

# Step 2: Bring in the official secure n8n image
FROM n8nio/n8n:latest

USER root

# Copy the package binaries and system libraries safely from our builder stage
COPY --from=alpine-builder /usr/bin/chromium-browser /usr/bin/chromium-browser
COPY --from=alpine-builder /usr/lib/ /usr/lib/
COPY --from=alpine-builder /lib/ /lib/

# Install the Puppeteer nodes using n8n's existing global npm path
RUN npm install -g puppeteer n8n-nodes-puppeteer --unsafe-perm=true --legacy-peer-deps

# Re-secure the container back to n8n's standard non-root user
USER node
