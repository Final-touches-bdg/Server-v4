# System Command Wrappers

This directory contains enhanced wrappers for system commands that provide additional functionality, better error messages, and color output compared to the standard Linux commands.

## Commands

- `man` - Enhanced manual page viewer
- `help` - Comprehensive help system with tutorials and examples
- `history` - Command history with search and other features
- `top` - Process monitoring utility
- `ps` - Process status viewer
- `mkdir` - Directory creation with enhanced feedback

## Features

1. **Color Output**: All commands provide color-coded output for better readability
2. **Improved Error Messages**: More helpful error messages with suggestions
3. **Enhanced Help**: Detailed help information with examples
4. **Graceful Fallbacks**: Uses system commands when available, provides # Let's create a few more essential system wrappers
# Create ls wrapper with enhanced color support
cat > improved_terminal/wrappers/system/ls << 'EOF'
#!/bin/bash
# Enhanced ls command with better color support and error handling

# Source shell functions if available
if [[ -f "$HOME/.local/lib/shell_functions.sh" ]]; then
  source "$HOME/.local/lib/shell_functions.sh"
fi

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Check if system ls exists
if command -v /bin/ls &>/dev/null; then
  # Check if color flag is supported
  if /bin/ls --color=auto &>/dev/null 2>&1; then
    # Add color by default if not explicitly specified
    if [[ "$*" != *"--color"* ]]; then
      /bin/ls --color=auto "$@"
    else
      /bin/ls "$@"
    fi
  else
    /bin/ls "$@"
  fi
  exit $?
fi

# Simple ls implementation if system command is unavailable
# Parse options
show_all=false
show_long=false
show_human=false
show_hidden=false
targets=()

for arg in "$@"; do
  if [[ "$arg" == "-"* ]]; then
    # Process option flags
    if [[ "$arg" == "-a" || "$arg" == "--all" ]]; then
      show_all=true
    elif [[ "$arg" == "-l" ]]; then
      show_long=true
    elif [[ "$arg" == "-h" || "$arg" == "--human-readable" ]]; then
      show_human=true
    elif [[ "$arg" == "-la" || "$arg" == "-al" ]]; then
      show_long=true
      show_all=true
    elif [[ "$arg" == "-lh" || "$arg" == "-hl" ]]; then
      show_long=true
      show_human=true
    elif [[ "$arg" == "-alh" || "$arg" == "-ahl" || "$arg" == "-lha" || "$arg" == "-lah" ]]; then
      show_all=true
      show_long=true
      show_human=true
    elif [[ "$arg" == "--help" ]]; then
      echo "Usage: ls [OPTION]... [FILE]..."
      echo "List information about the FILEs (the current directory by default)."
      echo
      echo "  -a, --all             do not ignore entries starting with ."
      echo "  -l                    use a long listing format"
      echo "  -h, --human-readable  with -l, print sizes in human readable format"
      echo "      --help            display this help and exit"
      exit 0
    else
      echo -e "${RED}ls: invalid option -- '${arg#-}'${NC}"
      echo "Try 'ls --help' for more information."
      exit 1
    fi
  else
    # It's a target directory/file
    targets+=("$arg")
  fi
done

# If no targets specified, use current directory
if [ ${#targets[@]} -eq 0 ]; then
  targets=(".")
fi

# Format file size to human readable if needed
format_size() {
  local size=$1
  
  if $show_human; then
    if [ "$size" -ge 1073741824 ]; then # 1 GB
      printf "%.1fG" "$((size / 1073741824)).$((size % 1073741824 / 107374182))"
    elif [ "$size" -ge 1048576 ]; then # 1 MB
      printf "%.1fM" "$((size / 1048576)).$((size % 1048576 / 104858))"
    elif [ "$size" -ge 1024 ]; then # 1 KB
      printf "%.1fK" "$((size / 1024)).$((size % 1024 / 102))"
    else
      printf "%d" "$size"
    fi
  else
    printf "%d" "$size"
  fi
}

# Color-code file types
colorize_filename() {
  local filename=$1
  
  if [ -d "$filename" ]; then
    # Directory
    echo -e "${BLUE}$filename${NC}"
  elif [ -L "$filename" ]; then
    # Symlink
    echo -e "${CYAN}$filename${NC}"
  elif [ -x "$filename" ]; then
    # Executable
    echo -e "${GREEN}$filename${NC}"
  elif [[ "$filename" == *.txt || "$filename" == *.md || "$filename" == *.log ]]; then
    # Text files
    echo -e "${YELLOW}$filename${NC}"
  elif [[ "$filename" == *.tar || "$filename" == *.gz || "$filename" == *.zip ]]; then
    # Archives
    echo -e "${RED}$filename${NC}"
  elif [[ "$filename" == *.jpg || "$filename" == *.jpeg || "$filename" == *.png || "$filename" == *.gif ]]; then
    # Images
    echo -e "${MAGENTA}$filename${NC}"
  else
    # Regular files
    echo "$filename"
  fi
}

# Process each target
for target in "${targets[@]}"; do
  # Check if target exists
  if [ ! -e "$target" ] && [ ! -d "$target" ]; then
    echo -e "${RED}ls: cannot access '$target': No such file or directory${NC}"
    continue
  fi
  
  # If more than one target, print target name
  if [ ${#targets[@]} -gt 1 ]; then
    echo -e "${YELLOW}$target:${NC}"
  fi
  
  # Get file list
  if [ -d "$target" ]; then
    # It's a directory, list its contents
    files=()
    while IFS= read -r -d $'\0' file; do
      basename=$(basename "$file")
      
      # Skip hidden files unless -a specified
      if [[ "$basename" == .* ]] && ! $show_all && [[ "$basename" != "." && "$basename" != ".." ]]; then
        continue
      fi
      
      files+=("$file")
    done < <(find "$target" -mindepth 1 -maxdepth 1 -print0 2>/dev/null)
    
    # Add . and .. if showing all
    if $show_all; then
      files=("$target/." "$target/.." "${files[@]}")
    fi
    
    # Sort files
    IFS=$'\n' sorted_files=($(sort <<<"${files[*]}"))
    unset IFS
    
    if $show_long; then
      # Print header for long format
      echo "total $(( ${#sorted_files[@]} ))"
      
      # Print in long format
      for file in "${sorted_files[@]}"; do
        # Get file info
        filename=$(basename "$file")
        if [ "$filename" == "." ]; then
          filename="."
          file="$target"
        elif [ "$filename" == ".." ]; then
          filename=".."
          file="$target/.."
        fi
        
        # File type
        if [ -d "$file" ]; then
          type="d"
        elif [ -L "$file" ]; then
          type="l"
        else
          type="-"
        fi
        
        # Permissions (simplified)
        if [ -r "$file" ]; then
          perm_r="r"
        else
          perm_r="-"
        fi
        
        if [ -w "$file" ]; then
          perm_w="w"
        else
          perm_w="-"
        fi
        
        if [ -x "$file" ]; then
          perm_x="x"
        else
          perm_x="-"
        fi
        
        perms="$type$perm_r$perm_w$perm_x$perm_r$perm_w$perm_x$perm_r$perm_w$perm_x"
        
        # Get owner and group (simplified)
        owner=$(stat -c "%U" "$file" 2>/dev/null || echo "user")
        group=$(stat -c "%G" "$file" 2>/dev/null || echo "user")
        
        # Get size
        size=$(stat -c "%s" "$file" 2>/dev/null || echo "0")
        size_formatted=$(format_size "$size")
        
        # Last modified time
        mod_time=$(stat -c "%y" "$file" 2>/dev/null | cut -d'.' -f1 || date "+%Y-%m-%d %H:%M:%S")
        
        # Print the entry
        printf "%-10s %-8s %-8s %8s %s " "$perms" "$owner" "$group" "$size_formatted" "$mod_time"
        echo -e "$(colorize_filename "$filename")"
      done
    else
      # Print in regular format
      for file in "${sorted_files[@]}"; do
        filename=$(basename "$file")
        if [ "$filename" == "." ]; then
          filename="."
        elif [ "$filename" == ".." ]; then
          filename=".."
        fi
        echo -e "$(colorize_filename "$filename")"
      done
    fi
  else
    # It's a file, just show its name
    filename=$(basename "$target")
    
    if $show_long; then
      # Get file info for long format
      # File type
      if [ -d "$target" ]; then
        type="d"
      elif [ -L "$target" ]; then
        type="l"
      else
        type="-"
      fi
      
      # Permissions (simplified)
      if [ -r "$target" ]; then
        perm_r="r"
      else
        perm_r="-"
      fi
      
      if [ -w "$target" ]; then
        perm_w="w"
      else
        perm_w="-"
      fi
      
      if [ -x "$target" ]; then
        perm_x="x"
      else
        perm_x="-"
      fi
      
      perms="$type$perm_r$perm_w$perm_x$perm_r$perm_w$perm_x$perm_r$perm_w$perm_x"
      
      # Get owner and group (simplified)
      owner=$(stat -c "%U" "$target" 2>/dev/null || echo "user")
      group=$(stat -c "%G" "$target" 2>/dev/null || echo "user")
      
      # Get size
      size=$(stat -c "%s" "$target" 2>/dev/null || echo "0")
      size_formatted=$(format_size "$size")
      
      # Last modified time
      mod_time=$(stat -c "%y" "$target" 2>/dev/null | cut -d'.' -f1 || date "+%Y-%m-%d %H:%M:%S")
      
      # Print the entry
      printf "%-10s %-8s %-8s %8s %s " "$perms" "$owner" "$group" "$size_formatted" "$mod_time"
      echo -e "$(colorize_filename "$filename")"
    else
      echo -e "$(colorize_filename "$filename")"
    fi
  fi
  
  # Add newline between targets
  if [ ${#targets[@]} -gt 1 ]; then
    echo ""
  fi
done

exit 0
