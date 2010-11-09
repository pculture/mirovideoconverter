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
    echo rm -f $incdir/x264.h
    rm -f $incdir/x264.h
    # Had to edit configures in each arch dir to change prefix away from /usr/local
    # passing enable-pic so we can create a shared dynamic library, otherwise
    # sets -mdynamic-no-pic so don't have relative relocatable fns
    echo CFLAGS="-arch $f -I$incdir -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5" CPPFLAGS="-arch $f -I$incdir -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5" LDFLAGS="-arch $f -L$libdir -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5" \
        ./configure --prefix=$installdir --host=$f-apple-darwin10 --enable-pic --enable-shared
    CFLAGS="-arch $f -I$incdir -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5" CPPFLAGS="-arch $f -I$incdir -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5" LDFLAGS="-arch $f -L$libdir -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5" \
        ./configure --prefix=$installdir --host=$f-apple-darwin10 --enable-pic --enable-shared && \
    make clean && \
    make && \
    make install
    popd
    echo
done
