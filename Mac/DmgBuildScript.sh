#!/bin/bash
app="Miro Video Converter"
version="1.0"
target="$app-$version.dmg"
targetWritable="$app-Writable.dmg"
rm -f "$target" "$targetWritable"
hdiutil create -megabytes 2 "$targetWritable" -layout NONE -partitionType Apple_HFS
disk=`hdid -nomount "$targetWritable"`
newfs_hfs -v "$app" $disk
hdiutil eject $disk
disk=`hdid "$targetWritable"`
echo cp -r "build/Release/$app.app" "/Volumes/$app"
echo "Drag app in... and press Return"
read
hdiutil eject "/Volumes/$app"
hdiutil convert -format UDZO "$targetWritable" -o "$target"
rm -f "$targetWritable"
