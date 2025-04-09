# Enhanced Terminal Environment - Render.com Deployment Guide

This guide explains how to deploy the Enhanced Terminal Environment to Render.com and have it automatically set up for all users.

## Prerequisites

- A GitHub repository with the iOS Terminal server code
- A Render.com account
- The enhanced-terminal-v1.0.tar.gz package

## Integration Steps

1. **Prepare your repository**:

   First, run the integration script to apply the necessary patches and prepare your code for deployment:

   ```bash
   ./render_integration/integrate.sh
   ```

   This script will:
   - Patch Dockerfile.flask to include the enhanced terminal package
   - Patch flask_server.py to automatically set up the environment for users
   - Copy the startup script to the correct location

2. **Add the enhanced terminal package**:

   Copy the enhanced terminal package to your repository:

   ```bash
   cp enhanced-terminal-v1.0.tar.gz .
   ```

3. **Commit and push changes**:

   ```bash
   git add enhanced-terminal-v1.0.tar.gz render_integration/ Dockerfile.flask flask_server.py
   git commit -m "Add enhanced terminal environment with automatic setup for Render.com"
   git push
   ```

## Deploy to Render.com

1. **Create a new Web Service**:

   - Log in to your Render.com dashboard
   - Click "New" and select "Web Service"
   - Connect your GitHub repository
   - Select the branch with your integrated code

2. **Configure the service**:

   - Name: `terminal-server` (or your preferred name)
   - Environment: `Docker`
   - Region: Choose the closest to your users
   - Branch: Your integrated branch
   - Plan: Select your preferred plan
   - Click "Create Web Service"

3. **Environment Variables** (optional):

   If you want to customize the terminal behavior, you can set the following environment variables:
   - SESSION_TIMEOUT: Time in seconds before sessions expire (default: 3600)
   - USE_AUTH: Whether to require authentication (default: false)
   - API_KEY: Custom API key for authentication

## Verification

Once your service is deployed, you can verify that the enhanced terminal environment is working:

1. **Connect to your terminal**:
   - Use your iOS client to connect to your Render.com service URL

2. **Test the enhanced commands**:
   - Try running `help` to see the enhanced help system
   - Use color-enabled commands like `ls` with color output
   - Try the package management with `pkg list-installed`

3. **Manual setup** (if needed):
   - If the automatic setup didn't work, users can run `setup-enhanced-linux`

## Troubleshooting

If you encounter issues:

1. **Check the logs** in the Render.com dashboard
2. **Verify file paths** - ensure the enhanced-terminal-v1.0.tar.gz is in the correct location
3. **Test the startup script** - you can manually run `/startup_script.sh` in the container
4. **Check permissions** - ensure scripts are executable

## Maintenance

To update the enhanced terminal environment:

1. **Create a new version of the package**
2. **Replace** enhanced-terminal-v1.0.tar.gz with your new version
3. **Commit and push** the changes
4. **Redeploy** your Render.com service

Your server will now automatically set up the enhanced terminal environment for all users!
