#!/bin/bash
# Enhanced Terminal Environment Setup Script

echo "Setting up Enhanced Terminal Environment..."

# Create necessary directories
mkdir -p $HOME/.local/bin
mkdir -p $HOME/.local/lib
mkdir -p $HOME/.local/etc
mkdir -p $HOME/bin

# Install command wrappers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Copy wrappers
for dir in $SCRIPT_DIR/wrappers/*; do
  if [ -d "$dir" ]; then
    echo "Installing $(basename "$dir") wrappers..."
    for cmd in "$dir"/*; do
      if [ -f "$cmd" ] && [ -x "$cmd" ]; then
        cp "$cmd" "$HOME/.local/bin/"
        chmod +x "$HOME/.local/bin/$(basename "$cmd")"
        echo "  Installed: $(basename "$cmd")"
      fi
    done
  fi
done

# Set up basic config files
if [ ! -f "$HOME/.bashrc" ] || ! grep -q "Enhanced Terminal" "$HOME/.bashrc"; then
  echo "Setting up bash configuration..."
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
  echo "Creating profile..."
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

echo "Enhanced Terminal Environment setup complete!"
echo "Please log out and log back in, or run: source ~/.bashrc"
