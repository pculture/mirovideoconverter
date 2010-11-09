#!/bin/bash
baseinstalldir=$PWD/../local
lib=${PWD%%*/}
echo "$lib:"

for f in `cat ../archlist.txt`
#for f in i386
do 
    installdir=$baseinstalldir/$f
    incdir=$installdir/include
    libdir=$installdir/lib
    bindir=$installdir/bin
    echo "   ***"
    echo "   $f"
    echo "   ***"
    pushd $f
    echo Removing old installed include dirs
    echo rm -rf $incdir/libavcodec $incdir/libavdevice $incdir/libavformat $incdir/libavutil $incdir/libswscale
    rm -rf $incdir/libavcodec $incdir/libavdevice $incdir/libavformat $incdir/libavutil $incdir/libswscale
    aarch=$f
    if [ $f = i386 ]; then aarch=x86_32; fi
    echo CFLAGS="-I$incdir -arch $f -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5" CPPFLAGS="-I$incdir -arch $f -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5" LDFLAGS="-L$libdir -arch $f -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5" \
        ./configure --prefix=$installdir --enable-static --enable-shared --enable-gpl --enable-version3 --enable-libmp3lame \
        --enable-pthreads --enable-libvorbis --enable-libx264 --enable-libxvid --enable-libspeex \
        --enable-libopencore_amrwb --enable-libopencore_amrnb --enable-libvpx --enable-memalign-hack \
        --disable-debug --disable-stripping --arch=$aarch
    CFLAGS="-I$incdir -arch $f -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5" CPPFLAGS="-I$incdir -arch $f -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5" LDFLAGS="-L$libdir -arch $f -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5" \
        ./configure --prefix=$installdir --enable-static --enable-shared --enable-gpl --enable-version3 --enable-libmp3lame \
        --enable-pthreads --enable-libvorbis --enable-libx264 --enable-libxvid --enable-libspeex \
        --enable-libopencore_amrwb --enable-libopencore_amrnb --enable-libvpx --enable-memalign-hack \
        --disable-debug --disable-stripping --arch=$aarch && \
    make clean && \
    make && \
    make install
    echo gcc -L"/Users/cworth/OtherApps/ffmpeg/ffmpeg/$f"/libavcodec -L"/Users/cworth/OtherApps/ffmpeg/ffmpeg/$f"/libavdevice -L"/Users/cworth/OtherApps/ffmpeg/ffmpeg/$f"/libavfilter -L"/Users/cworth/OtherApps/ffmpeg/ffmpeg/$f"/libavformat -L"/Users/cworth/OtherApps/ffmpeg/ffmpeg/$f"/libavutil -L"/Users/cworth/OtherApps/ffmpeg/ffmpeg/$f"/libpostproc -L"/Users/cworth/OtherApps/ffmpeg/ffmpeg/$f"/libswscale -Wl,-dynamic,-search_paths_first -L/Users/cworth/OtherApps/ffmpeg/ffmpeg/../local/$f/lib -arch $f -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5 -o ffmpeg_static ffmpeg.o cmdutils.o libavcore/libavcore.a libavdevice/libavdevice.a libavfilter/libavfilter.a libavformat/libavformat.a libavcodec/libavcodec.a libswscale/libswscale.a libavutil/libavutil.a -lz -lbz2 -lm ../../local/$f/lib/libmp3lame.a -lm ../../local/$f/lib/libopencore-amrnb.a -lm ../../local/$f/lib/libopencore-amrwb.a -lm ../../local/$f/lib/libspeex.a ../../local/$f/lib/libvorbisenc.a ../../local/$f/lib/libvorbis.a ../../local/$f/lib/libogg.a ../../local/$f/lib/libx264.a -lm ../../local/$f/lib/libxvidcore.a ../../local/$f/lib/libvpx.a
    gcc -L"/Users/cworth/OtherApps/ffmpeg/ffmpeg/$f"/libavcodec -L"/Users/cworth/OtherApps/ffmpeg/ffmpeg/$f"/libavdevice -L"/Users/cworth/OtherApps/ffmpeg/ffmpeg/$f"/libavfilter -L"/Users/cworth/OtherApps/ffmpeg/ffmpeg/$f"/libavformat -L"/Users/cworth/OtherApps/ffmpeg/ffmpeg/$f"/libavutil -L"/Users/cworth/OtherApps/ffmpeg/ffmpeg/$f"/libpostproc -L"/Users/cworth/OtherApps/ffmpeg/ffmpeg/$f"/libswscale -Wl,-dynamic,-search_paths_first -L/Users/cworth/OtherApps/ffmpeg/ffmpeg/../local/$f/lib -arch $f -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5 -o ffmpeg_static ffmpeg.o cmdutils.o libavcore/libavcore.a libavdevice/libavdevice.a libavfilter/libavfilter.a libavformat/libavformat.a libavcodec/libavcodec.a libswscale/libswscale.a libavutil/libavutil.a -lz -lbz2 -lm ../../local/$f/lib/libmp3lame.a -lm ../../local/$f/lib/libopencore-amrnb.a -lm ../../local/$f/lib/libopencore-amrwb.a -lm ../../local/$f/lib/libspeex.a ../../local/$f/lib/libvorbisenc.a ../../local/$f/lib/libvorbis.a ../../local/$f/lib/libogg.a ../../local/$f/lib/libx264.a -lm ../../local/$f/lib/libxvidcore.a ../../local/$f/lib/libvpx.a
    echo cp ffmpeg_static ../../local/$f/bin
    cp ffmpeg_static ../../local/$f/bin
    popd
done
