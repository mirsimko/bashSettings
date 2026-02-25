#!/bin/bash

# Script to update AI tools via npm
# Requires sudo privileges

echo "Starting AI tools update..."

# Update GEMINI CLI
echo "Updating GEMINI CLI..."
sudo npm update -g @google/generative-ai

# Update Claude Code
echo "Updating Claude Code..."
sudo npm update -g claude-code

# Update Codex
echo "Updating Codex..."
sudo npm update -g github-codex

# Update Codebuff
echo "Updating Codebuff..."
sudo npm update -g codebuff

# Update OpenCode
echo "Updating OpenCode..."
sudo npm update -g opencode

echo "All AI tools updated successfully!"
