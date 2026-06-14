#!/usr/bin/env bash
#
# Apply Raycast visual settings (a safe, non-sensitive subset of its prefs).
#
# NOTE: Raycast stores shortcuts/aliases, the global hotkey, themes, snippets,
# and quicklinks in an *encrypted* database (~/Library/Application Support/
# com.raycast.macos), NOT in plain preferences. Those cannot be a plaintext
# dotfile — carry them with Raycast Cloud Sync or an encrypted export (see
# README.md). This script only applies the cleanly-capturable visual settings.
#
set -u

if [ "$(uname -s)" != "Darwin" ]; then
  echo "Raycast is macOS-only; skipping."
  exit 0
fi

defaults write com.raycast.macos raycastPreferredWindowMode -string "compact"
defaults write com.raycast.macos raycastShouldFollowSystemAppearance -bool true
defaults write com.raycast.macos useHyperKeyIcon -bool false

echo "Raycast visual settings applied. Restart Raycast for them to take effect."
