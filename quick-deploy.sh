#!/bin/bash
# Quick deploy script for weekly reports
# Usage: ./quick-deploy.sh "clientname-oct20-26" "Client Name" "October 20-26, 2025"

CLIENT_DIR=$1
CLIENT_NAME=$2
DATE_RANGE=$3

if [ -z "$CLIENT_DIR" ] || [ -z "$CLIENT_NAME" ] || [ -z "$DATE_RANGE" ]; then
    echo "Usage: ./quick-deploy.sh \"clientname-oct20-26\" \"Client Name\" \"October 20-26, 2025\""
    exit 1
fi

echo "📊 Deploying report for $CLIENT_NAME..."

# Safety: only deploy a directory that actually exists
if [ ! -d "$CLIENT_DIR" ]; then
    echo "❌ Directory '$CLIENT_DIR' not found. Nothing staged."
    echo "   (Run from the repo root and pass an existing report folder.)"
    exit 1
fi

# Stage ONLY this client's report folder, plus index.html if it was edited
# to add the report link. Never blanket 'git add -A' — that would sweep in
# every other client's unpushed work and publish it by accident.
git add "$CLIENT_DIR"
if ! git diff --quiet -- index.html || git status --porcelain -- index.html | grep -q .; then
    git add index.html
fi

# Abort if nothing was actually staged
if git diff --cached --quiet; then
    echo "⚠️  Nothing staged for '$CLIENT_DIR'. No changes to deploy."
    exit 1
fi

echo "📦 Staging the following for deploy:"
git diff --cached --name-only | sed 's/^/   /'

# Commit and push
git commit -m "Add $CLIENT_NAME report for $DATE_RANGE"
git push

echo "✅ Report deployed!"
echo "🔗 URL: https://reports-blok.co/$CLIENT_DIR/"
echo ""
echo "📝 Don't forget to update index.html with:"
echo "<div class=\"report-item\">"
echo "    <a href=\"/$CLIENT_DIR/\">"
echo "        <div class=\"report-title\">$CLIENT_NAME</div>"
echo "        <div class=\"report-date\">Week of $DATE_RANGE</div>"
echo "    </a>"
echo "</div>"
