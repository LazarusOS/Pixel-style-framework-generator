#!/bin/bash
#
# F-zip: Universal recovery flashable zip generator for Linux & android
#
# Author: sunilpaulmathew <sunil.kde@gmail.com>
#
# Version 1.0.0
#

# This script is licensed under the terms of the GNU General Public License version 2, as published by the 
# Free Software Foundation, and may be copied, distributed, and modified under those terms.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the 
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#

#
# #####	Variables to be set manually...	#####
#

PROJECT_NAME="Pixel-style"	# please-enter-without-space.

PROJECT_VERSION="1.0.0"		# please-enter-without-space.
				# If the above two left as such, it will simply display "Flashing Pixel-style framework v.1.0.0 for kltekor"

COPYRIGHT="sunilpaulmathew@xda-developers.com"	# If left as such, it will display "(c) sunilpaulmathew@xda-developers.com"

DEVICE_VARIANT="kltekor"	# only one variant at a time (Presently supported variants: klte & kltekor)...

#
# #####	The End	#####
#

#
# System variables. Please do not touch unless you know what you are doing... 
#

COLOR_RED="\033[0;31m"
COLOR_GREEN="\033[1;32m"
COLOR_NEUTRAL="\033[0m"
PROJECT_ROOT=$PWD

echo -e $COLOR_GREEN"\n F-zip: Universal recovery flashable zip generator for Linux & android\n"$COLOR_NEUTRAL
#
echo -e $COLOR_GREEN"\n (c) sunilpaulmathew@xda-developers.com\n"$COLOR_NEUTRAL

# backing up original updater-script...

cp META-INF/com/google/android/updater-script $PROJECT_ROOT/backup.sh

DISPLAY_NAME="Flashing $PROJECT_NAME framework v. $PROJECT_VERSION for $DEVICE_VARIANT"

OUTPUT_FILE="$PROJECT_NAME-$DEVICE_VARIANT-v.$PROJECT_VERSION-$(date +"%Y%m%d").zip"

sed -i "s;###Flashing###;${DISPLAY_NAME};" META-INF/com/google/android/updater-script;
sed -i "s;###copyright###;(c) ${COPYRIGHT};" META-INF/com/google/android/updater-script;

# decpmpiling framework-res.apk...

cd working/

if [ -e framework-res/ ]; then
	rm -r framework-res/
fi

java -jar apktools.jar d framework-res.apk

# replacing required file...

if [ "klte" == "$DEVICE_VARIANT" ]; then
	cp klte.xml framework-res/res/values/colors.xml
fi

if [ "kltekor" == "$DEVICE_VARIANT" ]; then
	cp kltekor.xml framework-res/res/values/colors.xml
fi

# building new framework-res.apk...

java -jar apktools.jar b framework-res/ -c

# copying new framework-res.apk to "/system/framework/"...

mv framework-res/dist/framework-res.apk ../system/framework/framework-res.apk

# modifying updater script for framework-res...

cd ../

if [ -e system/framework/framework-res.apk ]; then
	sed -i "s;# set_perm-fwr;set_perm;" META-INF/com/google/android/updater-script;
fi

# hiding working directory from the output zip...

if [ -e .git/ ]; then
	mv working .git/
else
	mkdir .git	
	mv working .git/
fi
	
# generating recovery flashable zip file

zip -r9 --exclude=*.sh* --exclude=*.git* --exclude=*apktools.jar* --exclude=*README* --exclude=*placeholder* $OUTPUT_FILE *

# restoring original updater-script...

mv $PROJECT_ROOT/backup.sh META-INF/com/google/android/updater-script

# restoring working directory

mv .git/working $PROJECT_ROOT/

echo -e $COLOR_GREEN"\n everything done... $OUTPUT_FILE is generated in the root folder...\n"$COLOR_NEUTRAL
