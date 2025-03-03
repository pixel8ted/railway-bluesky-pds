FROM ghcr.io/bluesky-social/pds:latest

# Copy scripts
COPY scripts/start.sh /start.sh
COPY scripts/pdsadmin-wrapper.sh /usr/local/bin/pdsadmin
RUN chmod +x /start.sh /usr/local/bin/pdsadmin

# Create necessary directories
RUN mkdir -p /pds/data /pds/config

# Set the entrypoint
ENTRYPOINT ["/start.sh"]