#!/bin/bash

# Mount the installer image
hdiutil attach /Applications/Install\ OS\ X\ El\ Capitan.app/Contents/SharedSupport/InstallESD.dmg -noverify -nobrowse -mountpoint /Volumes/install_app

# Convert the boot image to a sparse bundle
hdiutil convert /Volumes/install_app/BaseSystem.dmg -format UDSP -o /tmp/elcap

# Increase the sparse bundle capacity to accommodate the packages
hdiutil resize -size 8g /tmp/elcap.sparseimage

# Mount the sparse bundle for package addition
hdiutil attach /tmp/elcap.sparseimage -noverify -nobrowse -mountpoint /Volumes/install_build

# Remove Package link and replace with actual files
rm /Volumes/install_build/System/Installation/Packages
cp -rp /Volumes/install_app/Packages /Volumes/install_build/System/Installation/

# Copy Base System
cp -rp /Volumes/install_app/BaseSystem.dmg /Volumes/install_build/
cp -rp /Volumes/install_app/BaseSystem.chunklist /Volumes/install_build/

# Unmount the installer image
hdiutil detach /Volumes/install_app

# Unmount the sparse bundle
hdiutil detach /Volumes/install_build

# Resize the partition in the sparse bundle to remove any free space
hdiutil resize -size `hdiutil resize -limits /tmp/elcap.sparseimage | tail -n 1 | awk '{ print $1 }'`b /tmp/elcap.sparseimage

# Convert the sparse bundle to ISO/CD master
hdiutil convert /tmp/elcap.sparseimage -format UDTO -o /tmp/elcap

# Remove the sparse bundle
rm /tmp/elcap.sparseimage

# Rename the ISO and move it to the desktop
mv /tmp/elcap.cdr elcap.iso
