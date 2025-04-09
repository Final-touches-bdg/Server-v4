#!/bin/bash
# Integration script for Enhanced Terminal Environment on Render.com

# Define colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Integrating Enhanced Terminal Environment with Render.com deployment...${NC}"

# Check if we're in the right directory
if [ ! -f "Dockerfile.flask" ] || [ ! -f "flask_server.py" ]; then
  echo -e "${RED}Error: Integration must be run from the root of the repository.${NC}"
  exit 1
fi

# Backup original files
echo -e "${YELLOW}Backing up original files...${NC}"
cp Dockerfile.flask Dockerfile.flask.bak
cp flask_server.py flask_server.py.bak

# Apply patches
echo -e "${YELLOW}Applying patches...${NC}"
patch Dockerfile.flask < render_integration/Dockerfile.flask.patch
if [ $? -ne 0 ]; then
  echo -e "${RED}Error: Failed to patch Dockerfile.flask${NC}"
  echo -e "${YELLOW}Restoring backup...${NC}"
  cp Dockerfile.flask.bak Dockerfile.flask
  exit 1
fi

patch flask_server.py < render_integration/setup_user_environment.patch
if [ $? -ne 0 ]; then
  echo -e "${RED}Error: Failed to patch flask_server.py${NC}"
  echo -e "${YELLOW}Restoring backups...${NC}"
  cp Dockerfile.flask.bak Dockerfile.flask
  cp flask_server.py.bak flask_server.py
  exit 1
fi

# Copy startup script to the right location
echo -e "${YELLOW}Copying startup script...${NC}"
mkdir -p render_integration
cp render_integration/startup_script.sh render_integration/

# Verify integration
echo -e "${GREEN}Integration complete!${NC}"
echo -e "${YELLOW}To deploy:${NC}"
echo "1. Commit and push these changes to your repository"
echo "2. Deploy to Render.com"
echo "3. When users connect, the enhanced environment will be available automatically"
echo
echo -e "${BLUE}Note:${NC} Users can run 'setup-enhanced-linux' to manually set up the environment if needed."

exit 0
