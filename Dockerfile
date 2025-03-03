FROM ghcr.io/bluesky-social/pds:latest

# Copy scripts
COPY scripts/start.sh /start.sh
COPY scripts/pdsadmin-wrapper.sh /usr/local/bin/pdsadmin
COPY scripts/generate-keys.js /app/scripts/generate-keys.js

# Ensure scripts have proper permissions
RUN chmod +x /start.sh /usr/local/bin/pdsadmin

# Create necessary directories
RUN mkdir -p /pds/data /pds/config /app/scripts && \
    chmod 755 /pds /pds/data /pds/config /app/scripts

# Set the entrypoint
ENTRYPOINT ["/bin/sh", "/start.sh"]