#!/bin/bash
# The Light - Automatic Backup Script (Linux/Mac)
# This script commits and pushes all changes to GitHub

MESSAGE="${1:-Auto-backup: $(date '+%Y-%m-%d %H:%M:%S')}"

echo "Starting backup..."
echo "Message: $MESSAGE"

# Check if there are any changes
if [ -z "$(git status --porcelain)" ]; then
    echo "No changes to commit."
    exit 0
fi

# Add all changes
echo "Adding changes..."
git add .

# Commit with message
echo "Committing changes..."
git commit -m "$MESSAGE"

# Push to remote
echo "Pushing to GitHub..."
git push origin main

if [ $? -eq 0 ]; then
    echo "Backup completed successfully!"
else
    echo "Backup failed. Please check the error messages above."
    exit 1
fi



