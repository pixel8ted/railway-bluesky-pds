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

# Run the key generation script
echo "Running pds key generation script..."
node /app/scripts/generate-keys.js

# Check if key files exist and are readable
if [ -f "/pds/config/plc-rotation-key.json" ]; then
  echo "PLC rotation key exists:"
  cat /pds/config/plc-rotation-key.json
  # Extract the key content for environment variable
  PLC_ROTATION_KEY=$(cat /pds/config/plc-rotation-key.json)
else
  echo "ERROR: PLC rotation key file does not exist"
  exit 1
fi

if [ -f "/pds/config/server-key.json" ]; then
  echo "Server key exists:"
  cat /pds/config/server-key.json
  # Extract the key content for environment variable
  SERVER_DID_KEY=$(cat /pds/config/server-key.json)
else
  echo "ERROR: Server key file does not exist"
  exit 1
fi

# Start the PDS service with explicit environment variables
echo "Starting PDS service..."
echo "Running: node /app/index.js"

# Use the env command to set all environment variables explicitly
# Note: We're setting the actual key content as environment variables
exec env \
  PDS_HOSTNAME="${PDS_HOSTNAME}" \
  PDS_JWT_SECRET="${PDS_JWT_SECRET}" \
  PDS_ADMIN_PASSWORD="${PDS_ADMIN_PASSWORD}" \
  PDS_DATA_DIRECTORY="/pds/data" \
  PDS_BLOBSTORE_DISK_LOCATION="/pds/data/blobs" \
  PDS_BLOBSTORE_DISK_TMP_LOCATION="/pds/data/blobs-temp" \
  PDS_DID_PLC_URL="${PDS_DID_PLC_URL:-https://plc.directory}" \
  PDS_REPORT_SERVICE="${PDS_REPORT_SERVICE:-https://mod.bsky.app}" \
  PDS_CRAWLERS="${PDS_CRAWLERS:-https://relay.bsky.network}" \
  PDS_HANDLE_RESOLVER="${PDS_HANDLE_RESOLVER:-https://handle.bsky.network}" \
  PDS_INVITE_REQUIRED="${PDS_INVITE_REQUIRED:-true}" \
  PDS_EMAIL_SMTP_URL="${PDS_EMAIL_SMTP_URL:-}" \
  PDS_EMAIL_FROM_ADDRESS="${PDS_EMAIL_FROM_ADDRESS:-}" \
  PDS_PLC_ROTATION_KEY="${PLC_ROTATION_KEY}" \
  PDS_SERVER_DID_KEY="${SERVER_DID_KEY}" \
  LOG_LEVEL="${LOG_LEVEL:-info}" \
  node /app/index.js