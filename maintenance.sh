#!/bin/bash

echo "Maintenance Script Starting..."

# Get docker folders
DDIRS=`ls /home/rotide | grep docker-`
# Set Backup Dir
BDIR=/home/rotide/backups
# Set Backup Timestamp
BTS=$(date +%Y%m%d%H%M%S)

# Patch/Update OS (Apt)
echo "Maintenance: Patching OS..."
sudo apt update
sudo apt upgrade -y
sudo apt autoremove
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
  sudo tar -czf $BDIR/$i.backup.$BTS.tar.gz ~/$i
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

# Docker: Pre-Up Verification/Scripts

# Docker: Up/Start
for i in $DDIRS
do
  echo "Docker: Starting $i..."
  docker compose -f ~/$i/docker-compose.yml up -d
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
