#!/bin/bash
# note ** speex and vorbis require libogg to be compiled first
# note ** MUST remove old include files from share/include directories before
#         they get used instead of the new ones in the compiling library src dir **
# note added this to ffmpeg build script and libx264 build script
# note to see what ffmpeg is doing in LD call, replace $(LD) with gcc on line 78 right
# after this line: %_g$(EXESUF): %.o cmdutils.o $(FF_DEP_LIBS)# 
# or check out V at the top of common.mak
# note ** did you run ffmpegdiffsforvpx8.sh (on ffmpeg source code) to get vpx support ?

echo erasing local
rm -rf local/*
dirs="libogg-1.1.4 lame-3.98.3 libvorbis-1.3.1 opencore-amr-0.1.2"
dirs="$dirs speex-1.2rc1 xvidcore-11082010 x264-snapshot-20101107-2245 libvpx-v0.9.5 ffmpeg"
for f in $dirs; do
    echo *#*#*#*#*#*#*#*#*#*#*#*#*#*
    echo $f
    echo *#*#*#*#*#*#*#*#*#*#*#*#*#*
    pushd $f
    . ./build.sh
    popd
done
pushd local
mv i386/bin/ffmpeg i386/bin/ffmpeg_dynamic
mv ppc/bin/ffmpeg ppc/bin/ffmpeg_dynamic
mv x86_64/bin/ffmpeg x86_64/bin/ffmpeg_dynamic
mkdir -p universal/bin
echo lipo i386/bin/ffmpeg_dynamic x86_64/bin/ffmpeg_dynamic ppc/bin/ffmpeg_dynamic -output universal/bin/ffmpeg_dynamic -create
lipo i386/bin/ffmpeg_dynamic x86_64/bin/ffmpeg_dynamic ppc/bin/ffmpeg_dynamic -output universal/bin/ffmpeg_dynamic -create
echo lipo i386/bin/ffmpeg_static x86_64/bin/ffmpeg_static ppc/bin/ffmpeg_static -output universal/bin/ffmpeg_static -create
lipo i386/bin/ffmpeg_static x86_64/bin/ffmpeg_static ppc/bin/ffmpeg_static -output universal/bin/ffmpeg_static -create
popd
