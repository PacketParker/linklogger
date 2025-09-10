#!/bin/bash

# Define color variables for easier use
RED='\033[1;31m'
GREEN='\033[1;32m'
NC='\033[0m'  # No Color (reset to default)

# Function to detect the appropriate Python version
function check_python_version() {
    # Check for python3 first
    if command -v python3 &> /dev/null; then
        PYTHON_CMD="python3"
    elif command -v python &> /dev/null; then
        PYTHON_CMD="python"
    else
        printf "${RED}No Python installation found. Please install Python.${NC}\n"
        exit 1
    fi

    # Check Python version (>= 3.10)
    PYTHON_VERSION=$($PYTHON_CMD -c 'import platform; print(platform.python_version())')
    REQUIRED_VERSION="3.10"

    if [[ "$(printf '%s\n' "$REQUIRED_VERSION" "$PYTHON_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]]; then
        printf "${RED}Python version $PYTHON_VERSION is installed, but version 3.10 or higher is required.${NC}\n"
        exit 1
    fi
}

# Function to check if pip is installed
function check_pip_installed() {
    if ! $PYTHON_CMD -m pip --version &> /dev/null; then
        printf "${RED}Pip is not installed. Please install Pip before proceeding.${NC}\n"
        exit 1
    fi
}

# Function to check if yarn is installed
function check_yarn_installed() {
    if ! command -v yarn &> /dev/null; then
        printf "${RED}Yarn is not installed. Please install Yarn before proceeding.${NC}\n"
        exit 1
    fi
}

# If on Linux or macOS
if [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "darwin"* ]]; then
    check_python_version
    printf "${GREEN}Python version $PYTHON_VERSION is installed.${NC}\n"
    check_pip_installed
    printf "${GREEN}Pip is installed.${NC}\n"
    check_yarn_installed
    printf "${GREEN}Yarn is installed.${NC}\n"

    # Install the API dependencies
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        $PYTHON_CMD -m pip install --break-system-packages -r requirements.txt
    else
        $PYTHON_CMD -m pip install -r requirements.txt
    fi

    # Install the UI dependencies
    printf "${GREEN}Installing UI dependencies...${NC}\n"
    cd app || { printf "${RED}Failed to enter 'app' directory. Exiting.${NC}\n"; exit 1; }
    yarn install | head -n 5
    yarn add vite@^6 --dev | head -n 5
    cd .. || { printf "${RED}Failed to return to the previous directory. Exiting.${NC}\n"; exit 1; }
    printf "${GREEN}UI dependencies installed.${NC}\n"

    # Start the API and UI
    printf "${GREEN}Starting API and UI...${NC}\n"
    $PYTHON_CMD linklogger.py &
    cd app || { printf "${RED}Failed to enter 'app' directory. Exiting.${NC}\n"; exit 1; }
    yarn dev
fi

# If on Windows (MSYS environment)
if [[ "$OSTYPE" == "msys" ]]; then
    printf "${RED}This script is not for Windows. Please run dev.bat instead.${NC}\n"
    exit 1
fi
