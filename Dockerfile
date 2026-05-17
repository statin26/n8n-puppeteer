# Step 1: Use a Debian image to safely download the Linux-compatible Chromium binaries
FROM debian:bookworm-slim AS debian-builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    chromium \
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    librandr2 \
    libgbm1 \
    libasound2 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Step 2: Bring in the official n8n image
FROM n8nio/n8n:latest

USER root

# Copy over the true Chromium binaries and system core architectures
COPY --from=debian-builder /usr/bin/chromium /usr/bin/chromium
COPY --from=debian-builder /usr/lib/chromium/ /usr/lib/chromium/
COPY --from=debian-builder /usr/lib/x86_64-linux-gnu/ /usr/lib/x86_64-linux-gnu/
COPY --from=debian-builder /lib/x86_64-linux-gnu/ /lib/x86_64-linux-gnu/

# Install the Puppeteer community node using n8n's embedded NPM setup
RUN npm install -g puppeteer n8n-nodes-puppeteer --unsafe-perm=true --legacy-peer-deps

# Restore security constraints back to n8n's node user
USER node
