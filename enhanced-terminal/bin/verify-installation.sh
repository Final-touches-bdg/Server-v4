#!/bin/bash
# Script to verify the enhanced terminal environment installation

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Verifying Enhanced Terminal Environment Installation${NC}"
echo

# Check for command wrappers
echo -e "${YELLOW}Checking for command wrappers:${NC}"
commands=("ls" "help" "pkg" "top" "ifconfig" "nano" "vim")
missing=0

for cmd in "${commands[@]}"; do
  if command -v "$cmd" &>/dev/null; then
    echo -e "  ${GREEN}✓${NC} $cmd is available"
  elif [ -f "$HOME/.local/bin/$cmd" ]; then
    echo -e "  ${GREEN}✓${NC} $cmd is installed in ~/.local/bin"
  else
    echo -e "  ${RED}✗${NC} $cmd is not installed"
    missing=$((missing + 1))
  fi
done

# Check for configuration files
echo
echo -e "${YELLOW}Checking for configuration files:${NC}"
configs=("$HOME/.bashrc" "$HOME/.profile" "$HOME/.vimrc" "$HOME/.nanorc")
missing_configs=0

for cfg in "${configs[@]}"; do
  if [ -f "$cfg" ]; then
    echo -e "  ${GREEN}✓${NC} $cfg exists"
  else
    echo -e "  ${RED}✗${NC} $cfg is missing"
    missing_configs=$((missing_configs + 1))
  fi
done

# Check if PATH is properly set
echo
echo -e "${YELLOW}Checking environment:${NC}"
if echo "$PATH" | grep -q "$HOME/.local/bin"; then
  echo -e "  ${GREEN}✓${NC} PATH includes ~/.local/bin"
else
  echo -e "  ${RED}✗${NC} PATH does not include ~/.local/bin"
  echo -e "      Current PATH: $PATH"
  missing=$((missing + 1))
fi

# Check package database
if [ -f "$HOME/.local/var/lib/pkg/installed.txt" ]; then
  echo -e "  ${GREEN}✓${NC} Package database exists"
else
  echo -e "  ${YELLOW}!${NC} Package database not initialized"
fi

# Summary
echo
if [ $missing -eq 0 ] && [ $missing_configs -eq 0 ]; then
  echo -e "${GREEN}Enhanced Terminal Environment is correctly installed!${NC}"
  echo -e "${BLUE}You can now enjoy a more Linux-like terminal experience.${NC}"
else
  echo -e "${RED}Enhanced Terminal Environment installation is incomplete.${NC}"
  echo -e "${YELLOW}Please run 'setup-enhanced-terminal' to complete the installation.${NC}"
fi

exit $missing
