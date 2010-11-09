#!/bin/bash
pushd ffmpeg
for f in i386 x86_64 ppc; do
  pushd $f;
  for g in ../../mplayer-vp8-encdec-support/*.diff ../../mplayer-vp8-encdec-support/ffmpeg-only/*.diff ; do
    echo "$PWD: patch -p0 < $g"
    patch -p0 < $g
  done
popd
done
popd
   