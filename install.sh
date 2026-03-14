#!/bin/bash
# cmdsnap installer for macOS/Linux
# Run: curl -fsSL https://raw.githubusercontent.com/marioschiras/cmdsnap/master/install.sh | bash

set -e

INSTALL_DIR="$HOME/.cmdsnap"
REPO_URL="https://raw.githubusercontent.com/marioschiras/cmdsnap/master"

echo "Installing cmdsnap..."

# Create install directory
mkdir -p "$INSTALL_DIR/integrations"

# Download the script
echo "Downloading cmdsnap..."
curl -fsSL "$REPO_URL/integrations/zsh.cmdsnap.zsh" -o "$INSTALL_DIR/integrations/zsh.cmdsnap.zsh"

# Detect shell config file
if [ -n "$ZSH_VERSION" ] || [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
else
    SHELL_RC="$HOME/.zshrc"
fi

SOURCE_LINE="source \"$INSTALL_DIR/integrations/zsh.cmdsnap.zsh\""

# Check if already installed
if grep -q "cmdsnap" "$SHELL_RC" 2>/dev/null; then
    echo "✓ cmdsnap already in $SHELL_RC"
else
    echo "" >> "$SHELL_RC"
    echo "# cmdsnap - terminal command capture" >> "$SHELL_RC"
    echo "$SOURCE_LINE" >> "$SHELL_RC"
    echo "✓ Added cmdsnap to $SHELL_RC"
fi

echo ""
echo "✓ cmdsnap installed successfully!"
echo ""
echo "To start using cmdsnap, run:"
echo "  source $SHELL_RC"
echo ""
echo "Or restart your terminal."
echo ""
echo "Usage:"
echo "  cmdsnap        # Copy last command"
echo "  cmdsnap 3      # Copy last 3 commands"
echo "  cmdsnap list   # Show recent commands"
echo "  cmdsnap @2     # Copy command #2 from list"
