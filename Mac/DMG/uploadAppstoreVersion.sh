#!/bin/bash
app="Miro Video Converter"
appslash="Miro\ Video\ Converter"
if [ $# -lt 1 ]; then
    echo uploadAppstoreVersion.sh version
else
    zipfile="${app}-${1}-Appstore.zip"
    pushd ../build/Release
    zip -r "$zipfile" "$app.app"
    popd
    echo scp ../build/Release/$zipfile pculture@ftp-osl.osuosl.org:data/mirovideoconverter$testing/mac/.
    scp "../build/Release/$zipfile" pculture@ftp-osl.osuosl.org:data/mirovideoconverter/testing/mac/.
    rm "../build/Release/$zipfile"
    ssh pculture@ftp-osl.osuosl.org "cd data/mirovideoconverter/testing/mac; unlink $appslash-Appstore.zip; ln -s $appslash-${1}-Appstore.zip $appslash-Appstore.zip; cd ~; ./run-trigger"
fi
