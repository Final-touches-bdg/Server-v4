#!/bin/bash
# Script to integrate the enhanced terminal with iOS Terminal server

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}iOS Terminal Integration Script${NC}"
echo "This script will install the enhanced terminal environment into the iOS Terminal server."
echo

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

# Check if we're in the correct directory structure
if [[ ! -d "$PARENT_DIR/wrappers" ]]; then
  echo -e "${RED}Error: Could not find the wrappers directory.${NC}"
  echo "Please run this script from within the enhanced-terminal/bin directory."
  exit 1
fi

# Try to locate the iOS Terminal server directory
IOS_SERVER_DIR=""
possible_dirs=(
  "/app"
  "/workspace"
  "$HOME/ios-terminal-server"
  "../../"
  "../"
)

for dir in "${possible_dirs[@]}"; do
  if [[ -f "$dir/flask_server.py" ]]; then
    IOS_SERVER_DIR="$dir"
    break
  fi
done

if [[ -z "$IOS_SERVER_DIR" ]]; then
  echo -e "${YELLOW}Could not automatically find the iOS Terminal server directory.${NC}"
  read -p "Please enter the path to the iOS Terminal server directory: " IOS_SERVER_DIR
  
  if [[ ! -f "$IOS_SERVER_DIR/flask_server.py" ]]; then
    echo -e "${RED}Error: Could not find flask_server.py in the specified directory.${NC}"
    exit 1
  fi
fi

echo -e "${GREEN}Found iOS Terminal server at: $IOS_SERVER_DIR${NC}"

# Check for user_scripts directory
USER_SCRIPTS_DIR="$IOS_SERVER_DIR/user_scripts"
if [[ ! -d "$USER_SCRIPTS_DIR" ]]; then
  echo -e "${YELLOW}Creating user_scripts directory...${NC}"
  mkdir -p "$USER_SCRIPTS_DIR"
fi

# Create enhanced directory in user_scripts
ENHANCED_DIR="$USER_SCRIPTS_DIR/enhanced_terminal"
mkdir -p "$ENHANCED_DIR"
echo -e "${GREEN}Created enhanced terminal directory at: $ENHANCED_DIR${NC}"

# Copy files to the enhanced directory
echo -e "${YELLOW}Copying command wrappers and configuration files...${NC}"

# Copy wrappers
mkdir -p "$ENHANCED_DIR/wrappers"
cp -r "$PARENT_DIR/wrappers"/* "$ENHANCED_DIR/wrappers/"
chmod +x "$ENHANCED_DIR/wrappers"/*/*

# Copy configuration files
mkdir -p "$ENHANCED_DIR/etc"
cp -r "$PARENT_DIR/etc"/* "$ENHANCED_DIR/etc/" 2>/dev/null

# Copy library files
mkdir -p "$ENHANCED_DIR/lib"
cp -r "$PARENT_DIR/lib"/* "$ENHANCED_DIR/lib/" 2>/dev/null

# Copy setup script
cp "$PARENT_DIR/setup.sh" "$ENHANCED_DIR/"
chmod +x "$ENHANCED_DIR/setup.sh"

# Create a setup script in user_scripts
cat > "$USER_SCRIPTS_DIR/setup-enhanced-terminal" << 'SETUPSCRIPT'
#!/bin/bash
# Script to set up the enhanced terminal environment

# Define colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Setting up Enhanced Terminal Environment...${NC}"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENHANCED_DIR="$SCRIPT_DIR/enhanced_terminal"

if [[ ! -d "$ENHANCED_DIR" ]]; then
  echo "Error: Enhanced terminal directory not found."
  echo "Expected at: $ENHANCED_DIR"
  exit 1
fi

# Run the setup script
if [[ -x "$ENHANCED_DIR/setup.sh" ]]; then
  "$ENHANCED_DIR/setup.sh"
else
  echo "Error: Setup script not found or not executable."
  echo "Expected at: $ENHANCED_DIR/setup.sh"
  exit 1
fi

echo -e "${GREEN}Enhanced Terminal Environment setup complete!${NC}"
echo -e "${YELLOW}You can now use enhanced commands like:${NC}"
echo "  - ls (with color)"
echo "  - top (process viewer)"
echo "  - pkg (package management)"
echo "  - help (command documentation)"
echo
echo -e "${BLUE}Type 'help' for more information about available commands.${NC}"
SETUPSCRIPT

chmod +x "$USER_SCRIPTS_DIR/setup-enhanced-terminal"

echo -e "${GREEN}Installation complete!${NC}"
echo -e "${YELLOW}To set up the enhanced terminal environment, run:${NC}"
echo "  setup-enhanced-terminal"
echo
echo -e "${BLUE}This will install all command wrappers and configure your environment.${NC}"

exit 0
