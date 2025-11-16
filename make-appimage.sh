#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q authenticator | awk '{print $2; exit}')
export ARCH VERSION
export OUTPATH=./dist
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/scalable/apps/com.belmoussaoui.Authenticator.svg
export DESKTOP=/usr/share/applications/com.belmoussaoui.Authenticator.desktop
export DEPLOY_OPENGL=1
export DEPLOY_PIPEWIRE=1 # For camera portal
export STARTUPWMCLASS=authenticator # For Wayland, this is 'com.belmoussaoui.Authenticator', so this needs to be changed in desktop file manually by the user in that case until some potential automatic fix exists for this

# Trace and deploy all files and directories needed for the application (including binaries, libraries and others)
quick-sharun /usr/bin/authenticator

## Copy files needed for search integration
mkdir -p ./AppDir/share/gnome-shell/search-providers/
cp -v /usr/share/gnome-shell/search-providers/com.belmoussaoui.Authenticator.search-provider.ini ./AppDir/share/gnome-shell/search-providers/com.belmoussaoui.Authenticator.search-provider.ini
mkdir -p ./AppDir/share/dbus-1/services/
cp -v /usr/share/dbus-1/services/com.belmoussaoui.Authenticator.SearchProvider.service ./AppDir/share/dbus-1/services/com.belmoussaoui.Authenticator.SearchProvider.service

# Turn AppDir into AppImage
quick-sharun --make-appimage
