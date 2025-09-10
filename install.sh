#!/bin/bash

DEST="$HOME/funcheck"
ALIAS_NAME="funcheck"

if ! [ -f "./allowed.sh" ] || ! [ -d "./configs" ]; then
  echo "Error: vital files not found. Download the repository again"
  exit 1
fi

mkdir -p "$DEST"
mkdir -p "$DEST/configs"

cp ./allowed.sh "$DEST"
cp ./configs "$DEST" -r
chmod +x "$DEST/allowed.sh"

if ! grep -q "alias $ALIAS_NAME=" "$HOME/.zshrc"; then
  echo "$(tput setaf 5)░██████████                     ░██████ ░██                           ░██       ";
  echo "░██                            ░██   ░██░██                           ░██       ";
  echo "░██       ░██    ░██░████████ ░██       ░████████  ░███████  ░███████ ░██    ░██";
  echo "░█████████░██    ░██░██    ░██░██       ░██    ░██░██    ░██░██    ░██░██   ░██ ";
  echo "░██       ░██    ░██░██    ░██░██       ░██    ░██░█████████░██       ░███████  ";
  echo "░██       ░██   ░███░██    ░██ ░██   ░██░██    ░██░██       ░██    ░██░██   ░██ ";
  echo "░██        ░█████░██░██    ░██  ░██████ ░██    ░██ ░███████  ░███████ ░██    ░██";
  echo "                                                                         $(tput setaf 6)by mord"$(tput sgr0);
    echo "alias $ALIAS_NAME='$DEST/allowed.sh'" >> "$HOME/.zshrc"
    echo "Added alias '$ALIAS_NAME' to .zshrc"
else
    echo "Alias '$ALIAS_NAME' already exists in .zshrc"
fi

echo "Installation complete! Run 'source ~/.zshrc' or restart your terminal."

