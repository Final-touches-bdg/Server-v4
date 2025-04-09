#!/bin/bash
# Direct installer for enhanced terminal environment on Render.com

# Define colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Installing Enhanced Terminal Environment for Render.com...${NC}"

# Check if we're in the right directory
if [ ! -f "Dockerfile.flask" ] || [ ! -f "flask_server.py" ]; then
  echo -e "${RED}Error: This script must be run from the root of the repository.${NC}"
  exit 1
fi

# Backup original files
echo -e "${YELLOW}Creating backups...${NC}"
cp Dockerfile.flask Dockerfile.flask.bak
cp flask_server.py flask_server.py.bak
cp render.yaml render.yaml.bak 2>/dev/null || true

# Copy the enhanced terminal package
echo -e "${YELLOW}Setting up enhanced terminal package...${NC}"
mkdir -p render_integration
cp render_integration/startup_script.sh .

# Modify Dockerfile.flask
echo -e "${YELLOW}Modifying Dockerfile.flask...${NC}"
# Create a new Dockerfile with our modifications
cat > Dockerfile.flask.new << 'DOCKEREND'
FROM python:3.10-slim

# Set up environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Update and install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    gcc \
    g++ \
    make \
    git \
    openssh-client \
    openssl \
    python3-dev \
    default-libmysqlclient-dev \
    pkg-config \
    vim \
    nano \
    netcat-openbsd \
    sudo \
    tar \
    gzip \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set up work directory
WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir gunicorn

# Add www-data to sudoers (needed for some operations in the container)
RUN echo "www-data ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/www-data-sudo && \
    chmod 0440 /etc/sudoers.d/www-data-sudo

# Copy application files
COPY flask_server.py .
COPY file_management.py .
COPY static/ ./static/

# Copy enhanced terminal package
COPY enhanced-terminal-v1.0.tar.gz .

# Create directories and add user scripts
COPY user_scripts/ ./user_scripts/
RUN mkdir -p logs user_data && \
    chmod +x user_scripts/*

# Copy and set up startup script
COPY startup_script.sh /startup_script.sh
RUN chmod +x /startup_script.sh

# Set up permissions for user data directory
RUN chown -R www-data:www-data user_data logs

# Expose the port
EXPOSE 3000

# Create startup script
RUN echo '#!/bin/bash\n\
# Run startup script\n\
/startup_script.sh\n\
\n\
# Start gunicorn\n\
exec gunicorn --bind 0.0.0.0:3000 --workers 12 --threads 6 --worker-class gthread --worker-connections 1000 --timeout 90 --keep-alive 5 --max-requests 500 --max-requests-jitter 100 --graceful-timeout 30 --log-level info --preload flask_server:app\n\
' > /start.sh && chmod +x /start.sh

# Start using the startup script
CMD ["/start.sh"]
DOCKEREND

# Update flask_server.py
echo -e "${YELLOW}Modifying flask_server.py...${NC}"
# Find the setup_user_environment function
SETUP_FUNC_LINE=$(grep -n "def setup_user_environment" flask_server.py | cut -d':' -f1)
if [ -z "$SETUP_FUNC_LINE" ]; then
  echo -e "${RED}Error: Could not find setup_user_environment function in flask_server.py${NC}"
  exit 1
fi

# Find where to insert our code (after the user_bin_dir creation)
INSERT_LINE=$(grep -n "user_bin_dir = os.path.join(home_dir, '.local', 'bin')" flask_server.py | cut -d':' -f1)
if [ -z "$INSERT_LINE" ]; then
  # Try alternative location
  INSERT_LINE=$(grep -n "if not os.path.exists(user_bin_dir):" flask_server.py | cut -d':' -f1)
  if [ -z "$INSERT_LINE" ]; then
    echo -e "${RED}Error: Could not find insertion point in flask_server.py${NC}"
    exit 1
  fi
fi

# Add a few lines to the insertion point to find where to put our code
INSERT_LINE=$((INSERT_LINE + 5))

# Split the file and insert our code
head -n $INSERT_LINE flask_server.py > flask_server.py.part1
tail -n +$((INSERT_LINE + 1)) flask_server.py > flask_server.py.part2

# Create the insertion code
cat > flask_server.py.insert << 'INSERTEND'
        # Setup enhanced Linux terminal environment
        enhanced_script = os.path.join(os.getcwd(), 'user_scripts', 'setup-enhanced-linux')
        if os.path.exists(enhanced_script) and os.access(enhanced_script, os.X_OK):
            try:
                print(f"Setting up enhanced Linux terminal environment for {home_dir}")
                subprocess.run(f"cd {home_dir} && {enhanced_script}", shell=True, timeout=30)
            except Exception as e:
                print(f"Error setting up enhanced Linux terminal: {str(e)}")
INSERTEND

# Combine the files
cat flask_server.py.part1 > flask_server.py.new
cat flask_server.py.insert >> flask_server.py.new
cat flask_server.py.part2 >> flask_server.py.new

# Create a modified render.yaml
echo -e "${YELLOW}Creating enhanced render.yaml...${NC}"
cat > render.yaml.new << 'RENDEREND'
services:
  - type: web
    name: terminal-server
    env: docker
    dockerfilePath: ./Dockerfile.flask
    plan: free  # Explicitly set to free tier
    buildCommand: echo "Setting up Enhanced Terminal Environment"
    envVars:
      - key: DEBUG
        value: false
      - key: PORT
        value: 3000
      - key: SESSION_TIMEOUT
        value: 3600  # 1 hour in seconds
      - key: USE_AUTH
        value: false  # Set to true if you want to require API key
      - key: API_KEY
        sync: false   # Will be generated if not provided
      - key: ENHANCED_TERMINAL
        value: true   # Enable the enhanced terminal environment
RENDEREND

# Create the setup-enhanced-linux script in user_scripts
echo -e "${YELLOW}Creating setup-enhanced-linux script...${NC}"
cat > user_scripts/setup-enhanced-linux << 'SETUPEND'
#!/bin/bash
# Script to set up the enhanced Linux terminal environment

# Define colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Setting up Enhanced Linux Terminal Environment...${NC}"

# Create necessary directories
mkdir -p $HOME/.local/bin
mkdir -p $HOME/.local/lib
mkdir -p $HOME/.local/etc
mkdir -p $HOME/bin

# Check if enhanced terminal directory exists in the application
ENHANCED_DIR="/app/user_scripts/enhanced_terminal"
if [ ! -d "$ENHANCED_DIR" ]; then
  # Try to extract from the package
  if [ -f "/app/enhanced-terminal-v1.0.tar.gz" ]; then
    echo -e "${YELLOW}Extracting enhanced terminal package...${NC}"
    mkdir -p /tmp/enhanced_terminal
    tar -xzf /app/enhanced-terminal-v1.0.tar.gz -C /tmp/enhanced_terminal
    ENHANCED_DIR="/tmp/enhanced_terminal"
  else
    echo -e "${RED}Error: Enhanced terminal files not found.${NC}"
    exit 1
  fi
fi

# Copy wrappers to user's bin directory
for category in wrappers/networking wrappers/editors wrappers/system; do
  if [ -d "$ENHANCED_DIR/$category" ]; then
    echo -e "${YELLOW}Installing $category commands...${NC}"
    for cmd in "$ENHANCED_DIR/$category"/*; do
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
SETUPEND

chmod +x user_scripts/setup-enhanced-linux

# Apply all changes
echo -e "${YELLOW}Applying changes...${NC}"
mv Dockerfile.flask.new Dockerfile.flask
mv flask_server.py.new flask_server.py
mv render.yaml.new render.yaml
rm -f flask_server.py.part1 flask_server.py.part2 flask_server.py.insert

# Clean up
echo -e "${YELLOW}Cleaning up...${NC}"
rm -f Dockerfile.flask.rej flask_server.py.rej 2>/dev/null || true

echo -e "${GREEN}Enhanced Terminal Environment installation complete!${NC}"
echo -e "${YELLOW}To deploy:${NC}"
echo "1. Add the enhanced-terminal-v1.0.tar.gz file to your repository"
echo "2. Commit and push all changes"
echo "3. Deploy to Render.com"
echo
echo -e "${BLUE}Note:${NC} Users will automatically get the enhanced environment when connecting."

exit 0
