#!/bin/sh

set -eux

ARCH="$(uname -m)"
VERSION="$(cat ~/version)"
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"

# Variables used by quick-sharun
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export OUTNAME=Authenticator-"$VERSION"-anylinux-"$ARCH".AppImage
export DESKTOP=/usr/share/applications/com.belmoussaoui.Authenticator.desktop
export ICON=/usr/share/icons/hicolor/scalable/apps/com.belmoussaoui.Authenticator.svg
export DEPLOY_OPENGL=1
export DEPLOY_PIPEWIRE=1 # For camera portal
export STARTUPWMCLASS=authenticator # For Wayland, this is 'com.belmoussaoui.Authenticator', so this needs to be changed in desktop file manually by the user in that case until some potential automatic fix exists for this

# Trace and deploy all files and directories needed for the application (including binaries, libraries and others)
wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun
./quick-sharun /usr/bin/authenticator

## Copy files needed for search integration
mkdir -p ./AppDir/share/gnome-shell/search-providers/
cp -v /usr/share/gnome-shell/search-providers/com.belmoussaoui.Authenticator.search-provider.ini ./AppDir/share/gnome-shell/search-providers/com.belmoussaoui.Authenticator.search-provider.ini
mkdir -p ./AppDir/share/dbus-1/services/
cp -v /usr/share/dbus-1/services/com.belmoussaoui.Authenticator.SearchProvider.service ./AppDir/share/dbus-1/services/com.belmoussaoui.Authenticator.SearchProvider.service

## Set gsettings to save to keyfile, instead to dconf
echo "GSETTINGS_BACKEND=keyfile" >> ./AppDir/.env

# Make the AppImage with uruntime
./quick-sharun --make-appimage

# Prepare the AppImage for release
mkdir -p ./dist
mv -v ./*.AppImage* ./dist
mv -v ~/version     ./dist