#!/bin/bash

# Script to update AI tools via npm
# Requires sudo privileges

echo "Starting AI tools update..."

# Update Gemini CLI
echo "Updating Gemini CLI..."
sudo npm update -g @google/gemini-cli

# Update Claude Code
echo "Updating Claude Code..."
sudo npm update -g @anthropic-ai/claude-code

# Update Codex
echo "Updating Codex..."
sudo npm update -g @openai/codex

# Update Codebuff
echo "Updating Codebuff..."
sudo npm update -g codebuff

# Update OpenCode
echo "Updating OpenCode..."
sudo npm update -g opencode-ai

echo "All AI tools updated successfully!"
