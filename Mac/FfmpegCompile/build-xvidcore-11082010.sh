#!/bin/bash
baseinstalldir=$PWD/../local
lib=${PWD%%*/}
echo "$lib:"

for f in `cat ../archlist.txt`
#for f in ppc
do 
    installdir=$baseinstalldir/$f
    incdir=$installdir/include
    libdir=$installdir/lib
    echo "   ***"
    echo "   $f"
    echo "   ***"
    rm $incdir/xvid.h
    rm $libdir/libxvidcore*
    pushd $f/build/generic
#   Uncomment this and run it once because LDFLAGS aren't brought in
#   from environment like CFLAGS: (see next comment for why only once)
#   *** fix for LDFLAGS not getting passed into Makefile ***
#    g=$(echo sed -i bak \"s#\\$\(LDFLAGS\)#\\$\(LDFLAGS\) -arch $f#g\" Makefile); echo $g; eval $g

#   First apply this diff to the makefiles (once only, makefiles are never regenerated, even though we are regenerating configure file - configure just creates platform.inc) so we can see what's going on:
#94a95
#> 	@echo $(AS) $(AFLAGS) $< -o $(BUILD_DIR)/$@
#105a107
#> 	@echo $(CC) -c $(ARCHITECTURE) $(BUS) $(ENDIANNESS) $(FEATURES) $(SPECIFIC_CFLAGS) $(CFLAGS) $< -o $(BUILD_DIR)/$@
#114c116,117
#< 	@cd $(BUILD_DIR) && ar rc $(@F) $(OBJECTS) && $(RANLIB) $(@F)
#---
#> 	@echo cd $(BUILD_DIR) and ar rc $(@F) $(OBJECTS) and $(RANLIB) -c $(@F)
#> 	@cd $(BUILD_DIR) && ar rc $(@F) $(OBJECTS) && $(RANLIB) -c $(@F)
#134a138
#> 	@echo cd $(BUILD_DIR) and $(CC) $(LDFLAGS) $(OBJECTS) -o $(PRE_SHARED_LIB) $(SPECIFIC_LDFLAGS)

#   Below are steps to create configure to create the platform.inc files that
#   are included in the Makefiles
    rm configure
    ./bootstrap.sh
   echo CFLAGS="-isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5 -arch $f -I$incdir" CPPFLAGS="" LDFLAGS="" \
       ./configure --host=$f-apple-darwin10  --prefix $installdir
   CFLAGS="-isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5 -arch $f -I$incdir" CPPFLAGS="" LDFLAGS="" \
       ./configure --host=$f-apple-darwin10  --prefix $installdir && \
       make clean && \
       make && \
       make install
   cp ../../src/xvid.h $incdir
   cp =build/libxvidcore.a $libdir
   (cd $libdir && ln -s libxvidcore.4.dylib libxvidcore.dylib)
   popd
   echo
done

