# Enhanced Linux Terminal Environment - Installation Guide

## Prerequisites

- iOS Terminal application
- Access to the terminal server files
- Basic command-line knowledge

## Installation Options

### Option 1: Automatic Installation (Recommended)

1. Download and extract the enhanced-terminal.tar.gz package:
   ```bash
   mkdir -p ~/enhanced-terminal
   tar -xzf enhanced-terminal.tar.gz -C ~/enhanced-terminal
   cd ~/enhanced-terminal
   ```

2. Run the integration script:
   ```bash
   ./bin/integrate-with-ios-terminal.sh
   ```

3. When connected to the iOS Terminal application, run:
   ```bash
   setup-enhanced-terminal
   ```

4. Verify the installation:
   ```bash
   verify-installation.sh
   ```

### Option 2: Manual Installation

1. Download and extract the enhanced-terminal.tar.gz package.

2. Copy the files to the iOS Terminal server:
   ```bash
   # Create the enhanced terminal directory in user_scripts
   mkdir -p /path/to/ios-terminal/user_scripts/enhanced_terminal
   
   # Copy the wrappers
   cp -r wrappers/* /path/to/ios-terminal/user_scripts/enhanced_terminal/
   
   # Copy the setup script
   cp setup.sh /path/to/ios-terminal/user_scripts/enhanced_terminal/
   
   # Create the setup-enhanced-terminal script
   cp bin/setup-enhanced-terminal /path/to/ios-terminal/user_scripts/
   chmod +x /path/to/ios-terminal/user_scripts/setup-enhanced-terminal
   ```

3. When connected to the iOS Terminal application, run:
   ```bash
   setup-enhanced-terminal
   ```

## Configuration

After installation, you can customize the environment:

### Bash Configuration

Edit `~/.bashrc` to add custom aliases or functions:
```bash
# Add custom aliases
alias ll='ls -la'
alias cls='clear'

# Add custom functions
mkcd() {
  mkdir -p "$1" && cd "$1"
}
```

### Editor Configuration

Edit `~/.vimrc` or `~/.nanorc` to customize the editor behavior.

### Package Management

You can add custom packages to the package database:
```bash
echo "custom-package|Category|Description of the package" >> ~/.local/var/lib/pkg/available.txt
```

## Troubleshooting

### Command Not Found

If commands are not available after installation:
```bash
# Check if the command is installed
ls -la ~/.local/bin/

# Check if PATH includes ~/.local/bin
echo $PATH

# Reload your bash configuration
source ~/.bashrc
```

### Permission Issues

If you encounter permission errors:
```bash
# Make sure scripts are executable
chmod +x ~/.local/bin/*

# Check file ownership
ls -la ~/.local/bin/
```

### Integration Script Fails

If the integration script fails to locate the iOS Terminal server:
```bash
# Run with explicit path
./bin/integrate-with-ios-terminal.sh /path/to/ios-terminal
```

## Uninstallation

To remove the enhanced terminal environment:
```bash
# Remove command wrappers
rm -rf ~/.local/bin/*

# Remove configuration
rm ~/.bashrc ~/.profile

# Restore original configuration (if you made backups)
mv ~/.bashrc.bak ~/.bashrc
mv ~/.profile.bak ~/.profile
```

## Support

If you encounter any issues with the enhanced terminal environment, please check the documentation or report issues to the project maintainers.
