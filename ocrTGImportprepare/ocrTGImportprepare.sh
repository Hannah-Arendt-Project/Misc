#!/bin/bash

# Helper Script to prepare the Faksimilies and OCR TEI data for the import into TextGrid Lab
# it is meant for processing volume by volume. It
# * creates a copy of the volume (scans, OCR files)
# * runs the OCR2TEI converter on the volume
# * convertes the TIF files to JPEG
# * creates a folder Faksimilies with subfolders for each literature
# * creates a TEI_OCR folder with subfolders for each literature
#
# Requirements: Java runtime or SDK 1.8+, sed, ImageMagick
# License: Apache 2.0
# Author: Johannes Biermann
#

SRCDIR=$1
DESTDIR=$2
XMLSCHEMA=$3

OCRTEIVERSION=1.1.1

function checkbins {
	if [ ! -f ocr2tei-$OCRTEIVERSION.jar ]; then
    	echo "ocr2tei-$OCRTEIVERSION.jar not found. Please copy it into the same directory as this script. Aborting."
    	exit 1
	fi
	command -v java  >/dev/null 2>&1 || { echo "Java runtime is not installed.  Aborting." >&2; exit 1; }	
	command -v sed >/dev/null 2>&1 || { echo "sed not installed.  Aborting." >&2; exit 1; }
	command -v convert >/dev/null 2>&1 || { echo "ImageMagick convert not installed.  Aborting." >&2; exit 1; }
	if [[ "command -v java" ]]; then
    	version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    	#echo Found Java version "$version"
		if [[ "$version" < "1.8" ]]; then
			echo "Need Java runtime version 1.8 or better. Please update Java. Aborting. "
			exit 1
    	fi
	fi
}
checkbins

if [ -z "$SRCDIR" ]
then
	echo "source dir parameter is missing!"
	echo "usage ./ocrTGImportprepare.sh /path/to/src/dir /path/to/dest/dir schemaURI (optional)"
	exit 1	
elif [ ! -d "$SRCDIR" ]
then
	echo "source directory does not exist!"
	exit 1
fi

if [ -z "$DESTDIR" ]
then
	echo "destination dir parameter is missing!"
	echo "usage ./ocrTGImportprepare.sh /path/to/src/dir /path/to/dest/dir schemaURI (optional)"
	exit 1	
elif [ ! -d "$DESTDIR" ]
then
	echo "destination directory does not exist! Please create it before running this script"
	exit 1
fi

# First step make a copy of the SRCDIR into DESTDIR
echo "Creating copy of $SRCDIR into $DESTDIR"
cp -a $SRCDIR $DESTDIR

# next Run the OCR2TEI programm on DESTDIR

echo "Running OCR2TEI converter on $DESTDIR"
java -jar ocr2tei-$OCRTEIVERSION.jar dir -d $DESTDIR -f -s

basedir=$(basename $SRCDIR)
echo "Creating Faksimilies and TEI_OCR dir in $DESTDIR"
mkdir $DESTDIR/$basedir/Faksimilies
mkdir $DESTDIR/$basedir/TEI_OCR

# now loop around DESTDIR
shopt -s dotglob
find $DESTDIR/$basedir/* -prune -type d | while IFS= read -r d; do 
	curdir=$(basename $d) 
	if [ "$curdir" != "Faksimilies" ] && [ "$curdir" != "TEI_OCR" ] ;
	then
	   echo "Processing $d"
	   echo "creating $curdir in Faksimilies dir"
	   mkdir $DESTDIR/$basedir/Faksimilies/$curdir
	   echo "converting $d/Arendt*/* to JPEG"
	   convert $d/Arendt*/* -set filename: "%t" $DESTDIR/$basedir/Faksimilies/$curdir/%[filename:].jpg
	   echo "creating $curdir in TEI_OCR dir"
	   mkdir $DESTDIR/$basedir/TEI_OCR/$curdir
	   
	   if [ -n "$XMLSCHEMA" ]
	   then
	   		echo "inserting XML schema '$XMLSCHEMA' into TEI file"
	   		sed -i .bak '/<\?xml/ a\
<?xml-model href="'"$XMLSCHEMA"'" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
' $d/ocr/*TEI/*.xml
	   fi
	   
	   echo "copying TEI file from $d/ocr/*TEI/*.xml"
	   cp $d/ocr/*TEI/*.xml $DESTDIR/$basedir/TEI_OCR/$curdir
	   echo "###############################################"
	fi
done

echo "Finished."

echo "Performing cleanup"

shopt -s extglob
rm -rf $DESTDIR/$basedir/!(TEI_OCR|Faksimilies)

echo "Done."