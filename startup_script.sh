#!/bin/bash
# Startup script for the enhanced terminal environment
# This script will run when the container starts up

# Define colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Setting up Enhanced Terminal Environment on container startup...${NC}"

# Extract the enhanced terminal package
if [ -f /app/enhanced-terminal-v1.0.tar.gz ]; then
    echo -e "${YELLOW}Extracting enhanced terminal package...${NC}"
    mkdir -p /app/enhanced_terminal
    tar -xzf /app/enhanced-terminal-v1.0.tar.gz -C /app/enhanced_terminal
    
    # Copy wrappers to user_scripts directory
    echo -e "${YELLOW}Installing command wrappers...${NC}"
    mkdir -p /app/user_scripts/enhanced_terminal
    cp -r /app/enhanced_terminal/wrappers/* /app/user_scripts/enhanced_terminal/ 2>/dev/null
    cp /app/enhanced_terminal/setup.sh /app/user_scripts/enhanced_terminal/ 2>/dev/null
    chmod +x /app/user_scripts/enhanced_terminal/setup.sh 2>/dev/null
    
    # Create the setup-enhanced-linux script
    echo -e "${YELLOW}Creating setup script...${NC}"
    cat > /app/user_scripts/setup-enhanced-linux << 'SETUPSCRIPT'
#!/bin/bash
# Script to set up the enhanced Linux terminal environment

# Define colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Setting up Enhanced Linux Terminal Environment...${NC}"

# Create necessary directories
mkdir -p $HOME/.local/bin
mkdir -p $HOME/.local/lib
mkdir -p $HOME/.local/etc
mkdir -p $HOME/bin

# Copy wrappers
SCRIPT_DIR="/app/user_scripts/enhanced_terminal"

if [ ! -d "$SCRIPT_DIR" ]; then
  echo -e "${RED}Error: Enhanced terminal directory not found.${NC}"
  echo "Expected at: $SCRIPT_DIR"
  exit 1
fi

# Copy wrappers to user's bin directory
for category in networking editors system; do
  if [ -d "$SCRIPT_DIR/$category" ]; then
    echo -e "${YELLOW}Installing $category commands...${NC}"
    for cmd in "$SCRIPT_DIR/$category"/*; do
      if [ -f "$cmd" ]; then
        cp "$cmd" "$HOME/.local/bin/"
        chmod +x "$HOME/.local/bin/$(basename "$cmd")"
        echo -e "  ${GREEN}Installed:${NC} $(basename "$cmd")"
      fi
    done
  fi
done

# Set up bash configuration
if [ ! -f "$HOME/.bashrc" ] || ! grep -q "Enhanced Terminal" "$HOME/.bashrc"; then
  echo -e "${YELLOW}Setting up bash configuration...${NC}"
  cat >> "$HOME/.bashrc" << 'BASHRC'

# Enhanced Terminal Environment
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
alias ls='ls --color=auto'
alias ll='ls -la'
alias grep='grep --color=auto'
PS1='\[\033[01;32m\]\u@terminal\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
BASHRC
fi

# Create basic profile if it doesn't exist
if [ ! -f "$HOME/.profile" ]; then
  echo -e "${YELLOW}Creating profile...${NC}"
  cat > "$HOME/.profile" << 'PROFILE'
# ~/.profile - executed by login shells

# Source .bashrc if it exists
if [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
fi

# Set PATH
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
PROFILE
fi

echo -e "${GREEN}Enhanced Linux Terminal Environment setup complete!${NC}"
echo -e "${YELLOW}You can now use enhanced commands like:${NC}"
echo "  - ls (with color)"
echo "  - help (command documentation)"
echo "  - pkg (package management)"
echo "  - vim/nano (enhanced text editors)"
echo
echo -e "${BLUE}Type 'help' for more information about available commands.${NC}"
SETUPSCRIPT

    chmod +x /app/user_scripts/setup-enhanced-linux
    
    echo -e "${GREEN}Enhanced Terminal Environment integration complete!${NC}"
    echo "Users can set up the enhanced environment by running: setup-enhanced-linux"
else
    echo -e "${YELLOW}Enhanced terminal package not found. Skipping setup.${NC}"
fi

# Continue with normal container startup
exit 0
