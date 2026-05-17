FROM n8nio/n8n:latest

# Switch to root to install system packages
USER root

# Install Chromium and the exact dependencies needed for headless Chrome on Debian
RUN apt-get update && apt-get install -y --no-install-recommends \
    chromium \
    fonts-ipafont-gothic \
    fonts-wqy-zenhei \
    fonts-thai-tlwg \
    fonts-kacst \
    fonts-freefont-ttf \
    libxss1 \
    ghostscript \
    && rm -rf /var/lib/apt/lists/*

# Set Environment variables for Puppeteer
# n8n's Debian image puts chromium at /usr/bin/chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Install Puppeteer and the n8n community node globally
# We use the global npm directory that n8n recognizes
RUN npm install -g puppeteer n8n-nodes-puppeteer --unsafe-perm=true --legacy-peer-deps

# Switch back to the default 'node' user for security
USER node
