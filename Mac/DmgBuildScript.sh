#!/bin/bash
app="Miro Video Converter"
version="1.0"
target="$app-$version.dmg"
targetWritable="$app-Writable.dmg"
hdiutil eject "/Volumes/$app"
rm -f "$target" "$targetWritable"
hdiutil create -megabytes 50 "$targetWritable" -layout NONE -partitionType Apple_HFS
disk=`hdid -nomount "$targetWritable"`
newfs_hfs -v "$app" $disk
hdiutil eject $disk
disk=`hdid "$targetWritable"`
pushd "/Volumes/$app"
ln -s /Applications .
popd
cp -r "build/Release/$app.app" "/Volumes/$app"
mkdir "/Volumes/$app/.background"
cp ../MSWindows/Windows/resources/bg.jpg "/Volumes/$app/.background/."
open "/Volumes/$app"
open .
open "/Volumes/$app/.background"
echo "Drag app around... and press Return"
read
hdiutil eject "/Volumes/$app"
hdiutil convert -format UDZO "$targetWritable" -o "$target"
rm -f "$targetWritable"
