#!/bin/bash

BOLD=$(tput bold)
NORMAL=$(tput sgr0)
PINK='\033[1;35m'

show() {
    case $2 in
        "error")
            echo -e "${PINK}${BOLD}❌ $1${NORMAL}"
            ;;
        "progress")
            echo -e "${PINK}${BOLD}⏳ $1${NORMAL}"
            ;;
        *)
            echo -e "${PINK}${BOLD}✅ $1${NORMAL}"
            ;;
    esac
}

# Check if curl is installed 
if ! command -v curl &> /dev/null; then
    show "curl is not installed. Installing curl..." "progress"
    brew install curl
    if [ $? -ne 0 ]; then
        show "Failed to install curl. Please install it manually and rerun the script." "error"
        exit 1
    fi
fi

# Check for existing Node.js installations
EXISTING_NODE=$(which node)
if [ -n "$EXISTING_NODE" ]; then
    show "Existing Node.js found at $EXISTING_NODE. The script will install the latest version system-wide."
fi

# Fetch the latest Node.js version dynamically
show "Fetching latest Node.js version..." "progress"
LATEST_VERSION=$(curl -s https://nodejs.org/dist/latest/ | grep -oE 'node-v[0-9]+\.[0-9]+\.[0-9]+' | head -1 | sed 's/node-v//')
if [ -z "$LATEST_VERSION" ]; then
    show "Failed to fetch latest Node.js version. Please check your internet connection." "error"
    exit 1
fi
show "Latest Node.js version is $LATEST_VERSION"

# Extract the major version for NodeSource setup
MAJOR_VERSION=$(echo $LATEST_VERSION | cut -d. -f1)

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    show "Homebrew not found. Installing Homebrew..." "progress"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ $? -ne 0 ]; then
        show "Failed to install Homebrew. Please install it manually and rerun the script." "error"
        exit 1
    fi
fi

# Install Node.js and npm using Homebrew
show "Installing Node.js and npm..." "progress"
brew install node@${MAJOR_VERSION}
if [ $? -ne 0 ]; then
    show "Failed to install Node.js and npm." "error"
    exit 1
fi

# Verify installation and PATH availability
show "Verifying installation..." "progress"
if command -v node &> /dev/null && command -v npm &> /dev/null; then
    NODE_VERSION=$(node -v)
    NPM_VERSION=$(npm -v)
    INSTALLED_NODE=$(which node)
    show "Node.js $NODE_VERSION and npm $NPM_VERSION installed successfully at $INSTALLED_NODE."
else
    show "Installation completed, but node or npm not found in PATH." "error"
    show "This is unusual as /usr/local/bin should be in PATH. Please ensure /usr/local/bin is in your PATH variable (e.g., export PATH=/usr/local/bin:$PATH) and restart your shell."
    exit 1
fi
