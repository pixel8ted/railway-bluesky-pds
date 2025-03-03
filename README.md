# Bluesky PDS Railway Template

This template deploys a Bluesky Personal Data Server (PDS) on Railway.

## Deployment Options

### Option 1: One-Click Deploy

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/bluesky-pds)

### Option 2: Deploy from GitHub

1. Fork this repository
2. Create a new Railway project
3. Add this repository as a service
4. Configure the required environment variables
5. Deploy

### Option 3: Deploy with Railway CLI

```bash
# Clone this repository
git clone https://github.com/yourusername/railway-bluesky-pds.git
cd railway-bluesky-pds

# Initialize Railway project
railway init

# Add a volume for persistent storage
railway add

# Deploy
railway up
```

## Required Environment Variables

- `PDS_HOSTNAME`: Your domain name (e.g., example.com)

## Optional Environment Variables

- `PDS_JWT_SECRET`: Secret for JWT tokens (auto-generated if not provided)
- `PDS_ADMIN_PASSWORD`: Admin password (auto-generated if not provided)
- `PDS_INVITE_REQUIRED`: Whether invites are required (default: true)
- `PDS_EMAIL_SMTP_URL`: SMTP URL for email sending
- `PDS_EMAIL_FROM_ADDRESS`: From address for emails
- `LOG_LEVEL`: Logging level (default: info)

## DNS Configuration

You must configure your DNS with both:
1. An A record for your root domain pointing to Railway's IP
2. A wildcard A record (*.yourdomain.com) pointing to the same IP

From your DNS provider's control panel, set up a domain with records pointing to your server.

| Name | Type | Value | TTL |
|------|------|-------|-----|
| example.com | A | 12.34.56.78 | 600 |
| *.example.com | A | 12.34.56.78 | 600 |

Note:

- Replace `example.com` with your domain name.
- Replace `12.34.56.78` with your server's IP address.
- Some providers may use the `@` symbol to represent the root of your domain.
- The wildcard record is required when allowing users to create new accounts on your PDS.
- The TTL can be anything but 600 (10 minutes) is reasonable.


## Post-Deployment Steps

### 1. Create an Account

Using the Railway CLI:

```bash
railway connect
railway run pdsadmin account create
```

### 2. Create an Invite Code

```bash
railway run pdsadmin create-invite-code
```

### 3. Verify Your PDS is Working

Visit `https://yourdomain.com/xrpc/_health` in your browser. You should see a JSON response with a version.

### 4. Test WebSockets

WebSockets must be working for federation. Install `wsdump` and run:

```bash
wsdump "wss://yourdomain.com/xrpc/com.atproto.sync.subscribeRepos?cursor=0"
```

## Important Notes

- The PDS requires ports 80 and 443 to be accessible
- Railway automatically handles TLS certificates
- Make sure your domain has proper DNS configuration
- Keep your PDS updated regularly

## Troubleshooting

If you encounter issues:
- Check Railway logs for errors
- Verify DNS configuration
- Ensure WebSockets are properly configured
- Join the AT Protocol PDS Admins Discord for community support