#!/bin/bash

#docker compose -f ~/$1/docker-compose.yml rm -f
#docker compose -f ~/$1/docker-compose.yml pull
#docker compose -f ~/$1/docker-compose.yml up -d

echo "Maintenance Script Starting..."

# Update OS (Apt)
echo "Maintenance: Updating OS..."
sudo apt update
sudo apt upgrade -y
sudo apt autoremove
sudo apt clean
echo "Maintenance: Updating OS - Complete."

# Docker: Stop
for i in `ls | grep docker-`
do
  echo "Docker: Stopping $i..."
  docker compose -f ~/$i/docker-compose.yml stop
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
