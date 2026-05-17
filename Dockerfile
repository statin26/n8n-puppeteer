# Use a standard, complete Alpine base image
FROM alpine:3.20

# Install Chromium, native dependencies, Node, and Git
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

# Global environment variables for Puppeteer and n8n behavior
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV N8N_COMMUNITY_PACKAGES_ENABLED=true

# Create the 'node' system group and user manually in Alpine
RUN addgroup -g 1000 node && \
    adduser -u 1000 -G node -s /bin/sh -D node

# Set up the data directories with the correct permissions first
RUN mkdir -p /home/node/.n8n && chown -R node:node /home/node

# Set the working directory to the node user's safe space
WORKDIR /home/node

# Install n8n and puppeteer LOCALLY inside the project directory instead of globally
# This avoids Alpine's global binary symlink path errors
RUN npm install n8n n8n-nodes-puppeteer puppeteer --unsafe-perm=true --legacy-peer-deps

# Force n8n to listen on all interfaces so Railway's healthcheck proxy can see it
ENV N8N_PORT=5678
ENV N8N_LISTEN_ADDRESS=0.0.0.0
ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=false

# Expose n8n's standard runtime port
EXPOSE 5678

# Switch to the secure non-root user
USER node

# Start n8n using its direct node module execution path
CMD ["./node_modules/.bin/n8n", "start"]
