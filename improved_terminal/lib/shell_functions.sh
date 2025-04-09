#!/bin/bash
# Shell function library for enhanced terminal environment

# Standard colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Print colored message
print_message() {
  local color=$1
  local message=$2
  echo -e "${color}${message}${NC}"
}

# Info message (blue)
info() {
  print_message "${BLUE}" "$1"
}

# Success message (green)
success() {
  print_message "${GREEN}" "$1"
}

# Warning message (yellow)
warning() {
  print_message "${YELLOW}" "$1"
}

# Error message (red)
error() {
  print_message "${RED}" "$1"
}

# Check if a command exists
command_exists() {
  command -v "$1" &> /dev/null
}

# Check if running in Termux environment
is_termux() {
  [[ -n "$TERMUX_VERSION" ]] || [[ -d "$HOME/termux" ]]
}

# Check if we're in virtual environment
is_virtualenv() {
  [[ -n "$VIRTUAL_ENV" ]] || [[ -d "$HOME/venv" ]]
}

# Add a directory to PATH if it's not already included
add_to_path() {
  local dir="$1"
  if [[ -d "$dir" ]] && [[ ":$PATH:" != *":$dir:"* ]]; then
    export PATH="$dir:$PATH"
  fi
}

# Create directory if it doesn't exist
ensure_dir() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
  fi
}

# Create a symlink if it doesn't exist
ensure_symlink() {
  local src="$1"
  local dest="$2"
  
  if [[ ! -e "$dest" ]]; then
    ln -s "$src" "$dest"
  elif [[ ! -L "$dest" ]] || [[ "$(readlink "$dest")" != "$src" ]]; then
    rm -f "$dest"
    ln -s "$src" "$dest"
  fi
}

# Log a message to file
log_message() {
  local log_file="$HOME/.terminal.log"
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "[$timestamp] $1" >> "$log_file"
}
