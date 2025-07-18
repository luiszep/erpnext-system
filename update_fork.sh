#!/bin/bash

# Fetch updates from the official Frappe Docker repository
echo "Fetching updates from the upstream repository..."
git fetch upstream

# Switch to the main branch
echo "Switching to main branch..."
git checkout main

# Merge updates into the local main branch
echo "Merging updates into the local main branch..."
git merge upstream/main

# Push changes to your GitHub repository
echo "Pushing changes to your GitHub repository..."
git push origin main

echo "✅ Your fork is now up to date with the latest changes from the official repository!"
