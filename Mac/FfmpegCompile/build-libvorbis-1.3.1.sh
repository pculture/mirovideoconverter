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
    echo CFLAGS="-arch $f -I$incdir -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5" CPPFLAGS="-arch $f -I$incdir -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5" LDFLAGS="-arch $f -L$libdir -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5" \
        ./configure --host=$f-apple-darwin10  --prefix $installdir
    CFLAGS="-arch $f -I$incdir -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5" CPPFLAGS="-arch $f -I$incdir -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5" LDFLAGS="-arch $f -L$libdir -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5" \
        ./configure --host=$f-apple-darwin10  --prefix $installdir && \
    make clean && \
    make && \
    make install
    popd
    echo
done
