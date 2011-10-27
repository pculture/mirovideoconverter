#!/bin/bash
if [ $# -lt 1 ]; then
    echo addAndUploadVersion.sh version [release]
else
    if [ $# -lt 2 ] || ! [ $2 = release ]; then
        echo '** Uploading to TESTING dir **'
        testing=/testing
    else 
        echo '** Uploading to RELEASE dir **'
        testing=
    fi
    key=`ruby /Developer/Sparkle/Extras/Signing\ Tools/sign_update.rb Miro\ Video\ Converter-$1.dmg dsa_priv.pem`
    klen=`du -sk Miro\ Video\ Converter-$1.dmg`
    klen=${klen%%Miro*}
    length=$(( $klen*1024 ))
    echo adding key $key
    echo adding length $length
    cat >newCast.xml <<EOF
       <item>
          <title>Version $1</title>
          <sparkle:releaseNotesLink>
            http://ftp.osuosl.org/pub/pculture.org/mirovideoconverter/mac/$1.html
          </sparkle:releaseNotesLink>
          <pubDate>Sat, 20 Mar2010 11:00:00 -0400</pubDate>
          <enclosure url="http://ftp.osuosl.org/pub/pculture.org/mirovideoconverter/mac/Miro Video Converter-$1.dmg"
      	       sparkle:version="$1"
      	       sparkle:dsaSignature="$key"
      	       length="$length"
      	       type="application/octet-stream"  />
       </item>
EOF
    echo add newCast.xml to SparkleAppCast.xml, create $1.html, then press return
    open -a /Applications/Emacs.app SparkleAppCast.xml
    read
#    scp $1.html SparkleAppCast.xml Miro\ Video\ Converter-$1.dmg root@192.168.0.2://var/www/MiroVideoConverter/mac/.
    echo scp Miro\ Video\ Converter-$1.dmg $1.html SparkleAppCast.xml pculture@ftp-osl.osuosl.org:data/mirovideoconverter$testing/mac/.
    scp Miro\ Video\ Converter-$1.dmg $1.html SparkleAppCast.xml pculture@ftp-osl.osuosl.org:data/mirovideoconverter$testing/mac/.
    ssh pculture@ftp-osl.osuosl.org "cd data/mirovideoconverter/$testing/mac; touch timestamp; unlink Miro\ Video\ Converter.dmg; ln -s Miro\ Video\ Converter-$1.dmg Miro\ Video\ Converter.dmg; cd ~; ./run-trigger"
    rm newCast.xml
fi
