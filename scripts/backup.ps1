# The Light - Automatic Backup Script
# This script commits and pushes all changes to GitHub

param(
    [string]$Message = ""
)

# Get current timestamp
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# If no message provided, create a default one
if ([string]::IsNullOrWhiteSpace($Message)) {
    $Message = "Auto-backup: $timestamp"
}

Write-Host "Starting backup..." -ForegroundColor Cyan
Write-Host "Message: $Message" -ForegroundColor Gray

# Check if there are any changes
$status = git status --porcelain
if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Host "No changes to commit." -ForegroundColor Yellow
    exit 0
}

# Add all changes
Write-Host "Adding changes..." -ForegroundColor Cyan
git add .

# Commit with message
Write-Host "Committing changes..." -ForegroundColor Cyan
git commit -m $Message

# Push to remote
Write-Host "Pushing to GitHub..." -ForegroundColor Cyan
git push origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "Backup completed successfully!" -ForegroundColor Green
} else {
    Write-Host "Backup failed. Please check the error messages above." -ForegroundColor Red
    exit 1
}


