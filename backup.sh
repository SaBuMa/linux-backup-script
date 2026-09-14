#!/bin/bash
#
# backup.sh
#
# Archives and compresses every file in a target directory that has been
# modified within the last 24 hours, then moves the resulting archive into
# a destination directory.
#
# Usage:
#   ./backup.sh <target_directory> <destination_directory>
#
# Example:
#   ./backup.sh important-documents backups/
#
# Exit codes:
#   0  success (including the case where nothing needed to be backed up)
#   1  bad usage / invalid arguments
#

set -uo pipefail

# --- Validate arguments -----------------------------------------------------

if [[ $# -ne 2 ]]; then
  echo "Usage: $(basename "$0") target_directory_name destination_directory_name" >&2
  exit 1
fi

targetDirectory="$1"
destinationDirectory="$2"

if [[ ! -d "$targetDirectory" ]] || [[ ! -d "$destinationDirectory" ]]; then
  echo "Error: invalid directory path provided" >&2
  exit 1
fi

echo "Target Directory= $targetDirectory"
echo "Destination Directory= $destinationDirectory"

# --- Build the backup file name ---------------------------------------------

currentTS=$(date +%s)
backupFileName="backup-${currentTS}.tar.gz"

# --- Resolve absolute paths before changing directories ---------------------
# We're going to:
#   1. Go into the target directory
#   2. Create the backup archive
#   3. Move the backup archive to the destination directory

origAbsPath=$(pwd)

cd "$destinationDirectory" || exit 1
destAbsPath=$(pwd)

cd "$origAbsPath" || exit 1
cd "$targetDirectory" || exit 1

# --- Find files modified in the last 24 hours --------------------------------

yesterdayTS=$((currentTS - 24 * 60 * 60))

declare -a toBackup

for file in *; do
  # Skip anything that isn't a regular readable file (e.g. subdirectories)
  [[ -f "$file" ]] || continue

  if [[ $(date -r "$file" +%s) -gt $yesterdayTS ]]; then
    toBackup+=("$file")
  fi
done

# --- Archive, compress, and move ---------------------------------------------

if [[ ${#toBackup[@]} -eq 0 ]]; then
  echo "No files were modified in the last 24 hours. Nothing to back up."
  exit 0
fi

tar -czvf "$backupFileName" "${toBackup[@]}"
mv "$backupFileName" "$destAbsPath"

echo "Backup complete: ${destAbsPath}/${backupFileName}"
