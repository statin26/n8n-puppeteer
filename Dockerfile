# Stage 1: Install Chromium and dependencies in a Debian image that has apt-get
FROM debian:bookworm-slim AS chromium-deps

RUN apt-get update && apt-get install -y --no-install-recommends \
    chromium \
    ca-certificates \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    xdg-utils \
    && rm -rf /var/lib/apt/lists/*

# Stage 2: Copy Chromium into the n8n image
FROM n8nio/n8n:latest

USER root

# Copy Chromium binary and all required shared libraries from the Debian stage
COPY --from=chromium-deps /usr/bin/chromium /usr/bin/chromium
COPY --from=chromium-deps /usr/lib/chromium/ /usr/lib/chromium/
COPY --from=chromium-deps /usr/share/fonts/ /usr/share/fonts/
COPY --from=chromium-deps /usr/share/ca-certificates/ /usr/share/ca-certificates/
COPY --from=chromium-deps /etc/ssl/certs/ /etc/ssl/certs/
COPY --from=chromium-deps /lib/x86_64-linux-gnu/ /lib/x86_64-linux-gnu/
COPY --from=chromium-deps /usr/lib/x86_64-linux-gnu/ /usr/lib/x86_64-linux-gnu/

RUN npm install -g puppeteer n8n-nodes-puppeteer

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

USER node

