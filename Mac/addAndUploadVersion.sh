#!/bin/bash
if [ $# -lt 1 ]; then
    echo Need version string
else
    cd ~/CocoaApps/miro
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
	      http://colinspage.com/MiroVideoConverter/mac/$1.html
	    </sparkle:releaseNotesLink>
            <pubDate>Wed, 12 Mar2010 11:00:00 +0000</pubDate>
            <enclosure url="http://colinspage.com/MiroVideoConverter/mac/Miro Video Converter-$1.dmg"
		       sparkle:version="$1"
		       sparkle:dsaSignature="$key"
		       length="$length"
		       type="application/octet-stream"  />
         </item>
EOF
    echo add newCast.xml to SparkleAppCast.xml, create $1.html, then press return
    read
#    scp $1.html SparkleAppCast.xml Miro\ Video\ Converter-$1.dmg root@192.168.0.2://var/www/MiroVideoConverter/mac/.
    echo scp $1.html SparkleAppCast.xml Miro\ Video\ Converter-$1.dmg pculture@ftp-osl.osuosl.org:data/mirovideoconverter/mac/.
    scp $1.html SparkleAppCast.xml Miro\ Video\ Converter-$1.dmg pculture@ftp-osl.osuosl.org:data/mirovideoconverter/mac/.
    rm newCast.xml
fi