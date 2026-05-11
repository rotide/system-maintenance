#!/bin/bash

echo "Maintenance Script Starting..."

# Get docker folders
DDIRS=`ls ~ | grep docker-`
# Set Backup Dir
BDIR=~/backups
# Set Backup Timestamp
BTS=$(date +%Y%m%d%H%M%S)
# NAS Mount Check Location
NAS_MOUNT_CHECK=/mnt/downloads/seagate4tb/MOUNTED

# Create backup directory if it doesn't exist
if ! test -d $BDIR; then
  mkdir $BDIR
fi

# Patch/Update OS (Apt)
echo "Maintenance: Patching OS..."
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y
sudo apt clean
echo "Maintenance: Patching OS - Complete."

# Docker: Stop
for i in $DDIRS
do
  echo "Docker: Stopping $i..."
  docker compose -f ~/$i/docker-compose.yml stop
done

# Docker: Backup
for i in $DDIRS
do
  echo "Docker: Backing Up $i..."
  sudo tar -czf $BDIR/backup.$i.$BTS.tar.gz $i
done

# Docker: Remove old files/images
for i in $DDIRS
do
  echo "Docker: Cleaning $i..."
  docker compose -f ~/$i/docker-compose.yml rm -f
done

# Docker: Pull fresh
for i in $DDIRS
do
  echo "Docker: Pulling $i..."
  docker compose -f ~/$i/docker-compose.yml pull
done

# Docker: Up/Start
for i in $DDIRS
do
  echo "Docker: Starting $i..."
  # Check if NAS is a pre-requisite.
  if test -f $i/prereq.nas; then
    # If NAS is a pre-requisite, check if it is mounted.
    if test -f $NAS_MOUNT_CHECK; then
      # Test passed, bring up docker container.
      docker compose -f ~/$i/docker-compose.yml up -d
    else
      # Test failed.
      echo "Docker: ERROR: NAS Not Mounted... Skipping $i"
    fi
  else
    # NAS is not a prerequisite, just bring up the container.
    docker compose -f ~/$i/docker-compose.yml up -d
  fi
done

# If reboot required (Apt Update), reboot.
echo "Checking if reboot required..."
if test -f /var/run/reboot-required; then
  echo "Rebooting in 30 seconds..."
  sleep 30s
  echo `date` "-- Complete (Rebooting)" >> ~/maintenance.log
  sudo shutdown -r now
else
  echo "Reboot NOT required!"
  echo `date` "-- Complete (No Reboot)" >> ~/maintenance.log
fi

echo "Maintenance Script Complete."
