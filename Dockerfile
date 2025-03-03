FROM ghcr.io/bluesky-social/pds:latest

# Copy scripts
COPY scripts/start.sh /start.sh
COPY scripts/pdsadmin-wrapper.sh /usr/local/bin/pdsadmin

# Ensure scripts have proper permissions
RUN chmod +x /start.sh /usr/local/bin/pdsadmin

# Create necessary directories
RUN mkdir -p /pds/data /pds/config && \
    chmod 755 /pds /pds/data /pds/config

# Set the entrypoint
ENTRYPOINT ["/bin/sh", "/start.sh"]