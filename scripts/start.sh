#!/bin/sh

set -e

# Create data directories if they don't exist
mkdir -p /pds/data
mkdir -p /pds/config

# Generate environment file if it doesn't exist
if [ ! -f /pds/pds.env ]; then
  echo "Initializing PDS environment file..."
  
  # Check if required environment variables are set
  if [ -z "$PDS_HOSTNAME" ]; then
    echo "ERROR: PDS_HOSTNAME environment variable must be set"
    exit 1
  fi
  
  # Create environment file
  cat > /pds/pds.env << EOF
PDS_HOSTNAME=${PDS_HOSTNAME}
PDS_JWT_SECRET=${PDS_JWT_SECRET:-$(openssl rand -hex 32)}
PDS_ADMIN_PASSWORD=${PDS_ADMIN_PASSWORD:-$(openssl rand -hex 16)}
PDS_DATA_DIRECTORY=/pds/data
PDS_BLOBSTORE_DISK_LOCATION=/pds/data/blobs
PDS_BLOBSTORE_DISK_TMP_LOCATION=/pds/data/blobs-temp
PDS_DID_PLC_URL=${PDS_DID_PLC_URL:-https://plc.directory}
PDS_REPORT_SERVICE=${PDS_REPORT_SERVICE:-https://mod.bsky.app}
PDS_CRAWLERS=${PDS_CRAWLERS:-https://relay.bsky.network}
PDS_HANDLE_RESOLVER=${PDS_HANDLE_RESOLVER:-https://handle.bsky.network}
PDS_INVITE_REQUIRED=${PDS_INVITE_REQUIRED:-true}
PDS_EMAIL_SMTP_URL=${PDS_EMAIL_SMTP_URL:-}
PDS_EMAIL_FROM_ADDRESS=${PDS_EMAIL_FROM_ADDRESS:-}
LOG_LEVEL=${LOG_LEVEL:-info}
EOF
fi

# Start the PDS service
echo "Starting PDS service..."
exec node /app/index.js --env-file=/pds/pds.env
