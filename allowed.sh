#!/bin/bash

BINARY="$1"
FUNC_RAW="$2"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILES_DIR="$SCRIPT_DIR/configs/"
MLX_BINS=("fractol" "so_long" "fdf")
IS_MLX_PROJECT=0
MLX_WARNING=""
MLX_IGNORE=""

# Pallette
RESET=$(tput sgr0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)

# Checks whether the program was used correctly, displaying usage and exiting if not
if [ -z "$BINARY" ]; then
  echo "${YELLOW}Use: $0 <binary> \"function1, function2,...\""
  echo "or"
  echo "$0 <binary> (with \"binary\" being a proper 42 project executable like .pipex or .minishell etc.${RESET}"
  exit 2
fi

# Get list of allowed functions either from input or from .config file
BIN_NAME=$(basename "$BINARY")
if [ -n "$FUNC_RAW" ]; then
  ALLOWED=$(echo "$FUNC_RAW" | tr ',' '\n' | sed 's/^ *//;s/ *$//' | sort -u)
elif [ -f "$CONFIG_FILES_DIR/$BIN_NAME.config" ]; then
  ALLOWED=$(sort -u "$CONFIG_FILES_DIR/$BIN_NAME.config")
else
  echo "${RED}No function list given for an unknown binary file"
  echo "${YELLOW}If you are checking a 42 project make sure the binary file's name is correct${RESET}"
  exit 2
fi

# Load mlx project dependent rules
for mlx_bin in "${MLX_BINS[@]}"; do
  if [[ "$BIN_NAME" == "$mlx_bin" ]]; then
    IS_MLX_PROJECT=1
    if [ -f "$CONFIG_FILES_DIR/mlx_ignore.config" ]; then
      MLX_IGNORE=$(sort -u "$CONFIG_FILES_DIR/mlx_ignore.config")
    fi
    if [ -f "$CONFIG_FILES_DIR/mlx_maybe.config" ]; then
      MLX_WARNING=$(sort -u "$CONFIG_FILES_DIR/mlx_maybe.config")
    fi
    break
  fi
done

# Use objdump to extract every library function call in the binary
USED=$(objdump -T "$BINARY" \
  | grep '\*UND\*' \
  | awk '{print $NF}' \
  | grep -v '^$' \
  | grep -v '^__' \
  | sort -u)

if [[ -z "$USED" ]]; then
  echo "${YELLOW}No external functions found in $BIN_NAME${RESET}"
  exit 0
fi

status=0

# Loops over the functions used in the project, printing out allowed vs prohibited functions
for func in $USED; do
  # Skip any __foo function calls
  if [[ "$func" == __* ]]; then
    continue
  fi
  # Skip MLX functions for MLX projects
  if [[ $IS_MLX_PROJECT -eq 1 ]]; then
    if echo "$MLX_IGNORE" | grep -qx "$func"; then
      continue
    elif echo "$MLX_WARNING" | grep -qx "$func" && ! echo "$ALLOWED" | grep -qx "$func"; then
      echo "${YELLOW}⚠️ Warning: $func found. If the use of $func is not interal to MLX, this is a forbidden function!"
      continue
    fi
  fi
  # Check if the current function is in the allowed functions list or not
  if ! echo "$ALLOWED" | grep -qx "$func"; then
    echo "${RED}❌ Function found: $func${RESET}"
    status=1
  else
    echo "${GREEN}✅ Function found: $func${RESET}"
  fi
done

if [ $status -eq 0 ]; then
  echo "${GREEN}All used functions are allowed for $BIN_NAME${RESET}"
fi
exit $status
