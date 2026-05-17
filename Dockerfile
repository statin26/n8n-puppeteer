# Use a standard, complete Alpine base image
FROM alpine:3.20

# Install Chromium, native dependencies, Node, and GIT (required for community node repo cloning)
RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ttf-freefont \
    ghostscript \
    bash \
    nodejs \
    npm \
    git

# Global environment variables for Puppeteer
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV N8N_COMMUNITY_PACKAGES_ENABLED=true

# Install n8n, puppeteer, and the community node now that git is available
RUN npm install -g n8n puppeteer n8n-nodes-puppeteer --unsafe-perm=true --legacy-peer-deps

# Create standard non-root node user configuration for container security
RUN mkdir -p /home/node/.n8n && chown -R node:node /home/node

USER node
WORKDIR /home/node

# Expose n8n's standard runtime port
EXPOSE 5678

# Start n8n directly
CMD ["n8n", "start"]
