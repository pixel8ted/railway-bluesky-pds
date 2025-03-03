#!/bin/sh

set -e

# Debug information
echo "Current directory: $(pwd)"
echo "Listing /pds directory:"
ls -la /pds || echo "Directory /pds does not exist or is not accessible"

# Create directories if they don't exist
mkdir -p /pds/data /pds/config
chmod 755 /pds /pds/data /pds/config

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

  # Ensure the file has proper permissions
  chmod 644 /pds/pds.env
  
  # Verify the file was created
  echo "Environment file created:"
  ls -la /pds/pds.env || echo "Failed to create environment file"
  echo "Environment file contents:"
  cat /pds/pds.env || echo "Failed to read environment file"
fi

# Export environment variables directly
export PDS_HOSTNAME=${PDS_HOSTNAME}
export PDS_JWT_SECRET=${PDS_JWT_SECRET:-$(grep PDS_JWT_SECRET /pds/pds.env | cut -d= -f2)}
export PDS_ADMIN_PASSWORD=${PDS_ADMIN_PASSWORD:-$(grep PDS_ADMIN_PASSWORD /pds/pds.env | cut -d= -f2)}
export PDS_DATA_DIRECTORY=/pds/data
export PDS_BLOBSTORE_DISK_LOCATION=/pds/data/blobs
export PDS_BLOBSTORE_DISK_TMP_LOCATION=/pds/data/blobs-temp
export PDS_DID_PLC_URL=${PDS_DID_PLC_URL:-https://plc.directory}
export PDS_REPORT_SERVICE=${PDS_REPORT_SERVICE:-https://mod.bsky.app}
export PDS_CRAWLERS=${PDS_CRAWLERS:-https://relay.bsky.network}
export PDS_HANDLE_RESOLVER=${PDS_HANDLE_RESOLVER:-https://handle.bsky.network}
export PDS_INVITE_REQUIRED=${PDS_INVITE_REQUIRED:-true}
export PDS_EMAIL_SMTP_URL=${PDS_EMAIL_SMTP_URL:-}
export PDS_EMAIL_FROM_ADDRESS=${PDS_EMAIL_FROM_ADDRESS:-}
export LOG_LEVEL=${LOG_LEVEL:-info}

# Start the PDS service
echo "Starting PDS service..."
echo "Running: node /app/index.js"
exec node /app/index.js
