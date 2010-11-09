#!/bin/bash
baseinstalldir=$PWD/../local
lib=${PWD%%*/}
echo "$lib:"

for f in `cat ../archlist.txt`
do 
    installdir=$baseinstalldir/$f
    incdir=$installdir/include
    libdir=$installdir/lib
    echo "   ***"
    echo "   $f"
    echo "   ***"
    pushd $f
#    rm -rf build_dir
    mkdir build_dir
    pushd build_dir
    aarch=$f
    if [ $f = i386 ]; then aarch=x86; fi
    if [ $f = ppc ]; then aarch=ppc32; fi
    echo CFLAGS="-arch $f -I$incdir -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5" CPPFLAGS="-arch $f -I$incdir -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5" LDFLAGS="-arch $f -L$libdir -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5" \
        ../configure --target=$aarch-darwin9-gcc
    CFLAGS="-arch $f -I$incdir -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5" CPPFLAGS="-arch $f -I$incdir -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5" LDFLAGS="-arch $f -L$libdir -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5" \
        ../configure --target=$aarch-darwin9-gcc && \
        make
    mkdir $incdir/vpx
    cp ../vpx/*.h $incdir/vpx
    cp libvpx.a $libdir
    popd
    popd
    echo
done
