#!/bin/bash

################################
# Shell script to sync spare hard drive
# to a variety of folders stored on the NAS.
# Written by: Taylor Ivy
################################

# Check if directory exists, if not create it.
if [ ! -d ~/Documents/Drive-Sync-Logs ]; then
  mkdir ~/Documents/Drive-Sync-Logs
fi

# Get current date
currentDate=$(date +"%d-%m-%Y")

# Log all script output to file
exec > ./$currentDate-sync.log 2>&1

change=false

# rsync flags: recursive, symlinks, human-readable numbers,
# delete extraneous files from destination directory, output change summary
# It's doubtful we have intentions on deleting Movies or TV shows, so we remove the delete flag
echo "Syncing Documents..."
rsync -rlh --delete --itemize-changes "/media/library/Libraries/Documents/" "/media/personal/Documents/"

echo "Syncing Games..."
rsync -rlh --delete --itemize-changes "/media/library/Libraries/Games/"     "/media/personal/Games/"

echo "Syncing Music..."
rsync -rlh --delete --itemize-changes "/media/library/Libraries/Music/"     "/media/personal/Music/"

echo "Syncing Pictures..."
rsync -rlh --delete --itemize-changes "/media/library/Libraries/Pictures/"  "/media/personal/Pictures/"

echo "Syncing Videos..."
rsync -rlh --delete --itemize-changes "/media/library/Libraries/Videos/"    "/media/personal/Videos/"

echo "Syncing Movies..."
rsync -rlh --itemize-changes          "/media/library/Libraries/Movies/"    "/media/media/Movies/"

echo "Syncing TV..."
rsync -rlh --itemize-changes          "/media/library/Libraries/TV/"        "/media/media/TV/"

# Checks if log file contains any actions from rsync
# https://caissyroger.com/2020/10/06/rsync-itemize-changes/
if grep -q "\*[a-zA-Z]\|[>\|<\|c\|h\|.][f\|d\|L\|D\|S]" "./$currentDate-sync.log"; then
  change=true
fi

# Delete log file if nothing was synced
if [ "$change" = false ] ; then
  rm ./$currentDate-sync.log
fi

# Move log file to log folder.
if [ "$change" = true ] ; then
  mv ./$currentDate-sync.log ~/Documents/Drive-Sync-Logs/
fi

# Delete log files older than 90 days
find ~/Documents/Drive-Sync-Logs -name "*sync.log" -type f -mtime +90 -delete
