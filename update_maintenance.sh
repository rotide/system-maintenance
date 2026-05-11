#!/bin/bash

# Define Scripts Directory
BDIR=~/scripts

# Backup existing script.
mv $BDIR/maintenance.sh $BDIR/maintenance.sh.bak
# Download new copy of script to scripts folder.
wget -P $BDIR https://raw.githubusercontent.com/rotide/system-maintenance/refs/heads/main/maintenance.sh

# Modify executable flag on script(s)
chmod -x $BDIR/maintenance.sh.bak
chmod +x $BDIR/maintenance.sh

echo "Maintenance script updated."
