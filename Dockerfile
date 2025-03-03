FROM ghcr.io/bluesky-social/pds:latest

# Copy scripts with explicit paths
COPY scripts/start.sh /start.sh
COPY scripts/pdsadmin-wrapper.sh /usr/local/bin/pdsadmin

# Ensure scripts have proper permissions and line endings
RUN chmod +x /start.sh /usr/local/bin/pdsadmin && \
    # Fix potential line ending issues
    sed -i 's/\r$//' /start.sh && \
    sed -i 's/\r$//' /usr/local/bin/pdsadmin

# Create necessary directories
RUN mkdir -p /pds/data /pds/config

# Set the entrypoint
ENTRYPOINT ["/start.sh"]