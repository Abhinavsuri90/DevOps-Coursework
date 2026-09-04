#!/usr/bin/env bash
set -euo pipefail

# System Information Script
# Student: Abhinav

# 1. Store data using variables
CURRENT_DATE=$(date)
SYSTEM_HOSTNAME=$(hostname)
CURRENT_USER=$(whoami)

echo "=========================================="
echo "         SYSTEM INFORMATION SCRIPT        "
echo "=========================================="
echo "Date     : ${CURRENT_DATE}"
echo "Hostname : ${SYSTEM_HOSTNAME}"
echo "User     : ${CURRENT_USER}"
echo "=========================================="
echo ""

echo "--- Disk Usage ---"
df -h .
echo ""

# 2. Interactive input using read -p
read -p "Enter a directory name to create: " TARGET_DIR
read -p "Enter an output file name for process listing: " TARGET_FILE

# 3. Create directory using mkdir
mkdir -p "${TARGET_DIR}"
echo "Created directory: ${TARGET_DIR}"

# 4. Create file using touch
FILE_PATH="${TARGET_DIR}/${TARGET_FILE}"
touch "${FILE_PATH}"
echo "Created file: ${FILE_PATH}"

# 5. Store running processes using > output redirection
echo "--- Fetching Running Processes ---"
ps aux > "${FILE_PATH}"
echo "Running processes successfully saved to ${FILE_PATH}."
echo ""
echo "First 5 lines of saved file:"
head -n 5 "${FILE_PATH}"
