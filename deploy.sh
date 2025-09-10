#!/bin/bash

# ==============================================================================
# Simple AWS EC2 Flask Deployment Script
#
# This script provides a streamlined, bare-essentials deployment for a Flask
# application on an AWS Linux EC2 instance.
# ==============================================================================

# Exit immediately if a command exits with a non-zero status.
set -e

# --- CONFIGURATION ---
# Hardcode your repository details here
REPO_URL="https://github.com/mananvashisht1/flask-app.git"
REPO_NAME="flask-app"

echo "Deploying from: $REPO_URL"

# --- SYSTEM SETUP ---
echo "Updating system and installing Python, Git, and Pip..."
sudo yum update -y
sudo yum install -y python3 python3-pip git

# --- APPLICATION DEPLOYMENT ---
cd ~

echo "Cleaning up previous deployment..."
if [ -d "$REPO_NAME" ]; then
    rm -rf "$REPO_NAME"
fi

echo "Cloning the repository..."
git clone "$REPO_URL"

cd "$REPO_NAME"

echo "Installing Python dependencies globally..."
pip3 install -r requirements.txt

# --- APPLICATION EXECUTION ---
echo "Starting the Flask application..."
nohup python3 app.py > app.log 2>&1 &

echo "Deployment complete. Application is running."
echo "Use 'tail -f app.log' to monitor the application logs."

