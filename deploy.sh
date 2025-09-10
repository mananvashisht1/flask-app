#!/bin/bash

# ==============================================================================
# AWS EC2 Flask Deployment Script
#
# This script is designed to automate the deployment of a Flask application
# on an AWS Linux EC2 instance. It handles updating the system, installing
# necessary software, cloning the repository, and running the application.
# ==============================================================================

# Exit immediately if a command exits with a non-zero status.
set -e

# Define variables for the GitHub repository and branch
# Usage: ./deploy.sh <github_username> <repo_name> [<branch>]
GITHUB_USERNAME="mananvashisht1"
REPO_NAME="flask-app"
# BRANCH=${3:-main} # Default to 'main' branch if not specified

# Validate input
if [ -z "$GITHUB_USERNAME" ] || [ -z "$REPO_NAME" ]; then
    echo "Usage: ./deploy.sh <github_username> <repo_name> [<branch>]"
    exit 1
fi

echo "Deploying from: https://github.com/$GITHUB_USERNAME/$REPO_NAME.git on branch main"

# --- SYSTEM SETUP ---

# Update package list and install necessary packages.
# AWS Linux uses 'yum' instead of 'apt-get'.
echo "Updating system and installing Python, Git, and Pip..."
sudo yum update -y
sudo yum install -y python3 python3-pip git

# --- APPLICATION DEPLOYMENT ---

# Navigate to home directory
cd ~

# Clean up previous deployment to ensure a clean state
# This makes the script idempotent
echo "Cleaning up previous deployment..."
if [ -d "$REPO_NAME" ]; then
    rm -rf "$REPO_NAME"
fi

# Clone the repository
# Note: For private repositories, you must have your SSH key configured on the EC2 instance.
echo "Cloning the repository..."
git clone --branch "main" "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"

# Navigate into the project directory
cd "$REPO_NAME"

# --- PYTHON ENVIRONMENT SETUP ---

# Create a Python virtual environment to isolate dependencies.
echo "Creating and activating a Python virtual environment..."
python3 -m venv .venv
source .venv/bin/activate

# Install Python dependencies
echo "Installing Python dependencies..."
pip install -r requirements.txt

# --- APPLICATION EXECUTION ---

# Check if a previous instance of the app is running and kill it.
echo "Checking for and stopping any running Flask application..."
FLASK_PID=$(ps aux | grep 'python3 app.py' | grep -v 'grep' | awk '{print $2}')
if [ ! -z "$FLASK_PID" ]; then
    echo "Found running process with PID $FLASK_PID. Killing it..."
    kill -9 "$FLASK_PID"
fi

# Run the Flask application in the background.
# nohup prevents the process from being killed when the shell session ends.
# The output is redirected to a log file.
echo "Starting the Flask application..."
nohup python3 app.py > app.log 2>&1 &

echo "Deployment complete. Application is running. Check app.log for output."
echo "Use 'tail -f app.log' to monitor the application logs."
