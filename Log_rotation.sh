#!/bin/bash

# Variables
LOG_DIR="/var/log/myapp"  # Directory where log files are stored
ARCHIVE_DIR="/var/log/myapp/old_logs"  # Directory to store rotated logs
LOG_FILE="app.log"  # The log file to be rotated
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)  # Current timestamp for the rotated file
MAX_LOG_SIZE=10485760  # 10MB size threshold before rotating (in bytes)

# Ensure the archive directory exists
if [ ! -d "$ARCHIVE_DIR" ]; then
  mkdir -p "$ARCHIVE_DIR"
fi

# Check if log file exceeds the maximum size
if [ -f "$LOG_DIR/$LOG_FILE" ]; then
  LOG_SIZE=$(stat -c%s "$LOG_DIR/$LOG_FILE")
  
  if [ "$LOG_SIZE" -ge "$MAX_LOG_SIZE" ]; then
    echo "Rotating log file: $LOG_FILE"
    
    # Compress the old log and move it to the archive directory
    mv "$LOG_DIR/$LOG_FILE" "$ARCHIVE_DIR/$LOG_FILE.$TIMESTAMP"
    gzip "$ARCHIVE_DIR/$LOG_FILE.$TIMESTAMP"
    
    # Create a new empty log file
    touch "$LOG_DIR/$LOG_FILE"
    
    # Set appropriate permissions for the new log file (optional)
    chmod 644 "$LOG_DIR/$LOG_FILE"
    
    echo "Log rotation completed: $LOG_FILE -> $ARCHIVE_DIR/$LOG_FILE.$TIMESTAMP.gz"
  else
    echo "Log file is under size limit: $LOG_SIZE bytes"
  fi
else
  echo "Log file not found: $LOG_DIR/$LOG_FILE"
fi
