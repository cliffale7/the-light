# The Light - Backup Guide

This guide explains how to use the automatic backup system for The Light project.

## Quick Backup

### Windows (PowerShell)
```powershell
.\scripts\backup.ps1
```

Or with a custom message:
```powershell
.\scripts\backup.ps1 -Message "Your custom commit message"
```

### Linux/Mac (Bash)
```bash
chmod +x scripts/backup.sh
./scripts/backup.sh
```

Or with a custom message:
```bash
./scripts/backup.sh "Your custom commit message"
```

## When to Backup

### Automatic Backups (I'll handle these)
The AI assistant will automatically create backups:
- ✅ After major feature implementations
- ✅ After completing roadmap milestones
- ✅ After significant code refactoring
- ✅ After adding new game mechanics
- ✅ Before making breaking changes
- ✅ After fixing critical bugs
- ✅ When you explicitly request a backup

### Manual Backups (You can do these)
You should manually backup:
- Before experimenting with major changes
- After collecting/adding new assets
- After updating documentation
- Before trying something risky
- At the end of a work session

## Manual Git Commands

If you prefer to use git directly:

```bash
# Check status
git status

# Add all changes
git add .

# Commit with message
git commit -m "Your commit message"

# Push to GitHub
git push origin main
```

## Backup Best Practices

1. **Commit Messages**: Be descriptive about what changed
   - Good: "Implemented sacrifice ritual with memory preview"
   - Bad: "Update"

2. **Frequency**: Don't backup after every tiny change, but don't wait too long either
   - Good: After completing a feature or fixing a bug
   - Bad: After every single line change

3. **Before Major Changes**: Always backup before:
   - Refactoring large sections
   - Updating dependencies
   - Changing core game mechanics
   - Experimenting with new features

## Troubleshooting

### "No changes to commit"
This means all your changes are already committed. You're up to date!

### "Backup failed"
Check:
- Do you have internet connection?
- Is GitHub accessible?
- Are there merge conflicts?
- Do you have write access to the repository?

### "Permission denied" (Linux/Mac)
Make the script executable:
```bash
chmod +x scripts/backup.sh
```

## Repository Location

Your code is backed up to:
**https://github.com/cliffale7/the-light**

You can view it, download it, or clone it from there anytime.

---

*Remember: Regular backups protect your work. When in doubt, backup!*


