#!/bin/sh

for PACKAGE in xscreensaver xscreensaver-data xscreensaver-data-extra \
               xscreensaver-gl xscreensaver-gl-extra \
			   xscreensaver-screensaver-bsod \
			   xscreensaver-screensaver-webcollage
do
	if [ -e debian/$PACKAGE.install.stub ]; then
		cp debian/$PACKAGE.install.stub debian/$PACKAGE.install
	else
		rm -f debian/$PACKAGE.install
	fi
	rm -f debian/$PACKAGE.manpages
done

while read HACK PACKAGE COMMENT
do
	[ -z "$HACK" ] && continue
	[ $HACK != "${HACK#\#}" ] && continue
	echo usr/lib/xscreensaver/$HACK >> debian/$PACKAGE.install
	if [ -e debian/tmp/usr/share/man/man6/$HACK.6x ]; then
		echo debian/tmp/usr/share/man/man6/$HACK.6x \
		     >> debian/$PACKAGE.manpages
	fi
	if [ -e debian/tmp/usr/share/xscreensaver/config/$HACK.xml ]; then
		echo usr/share/xscreensaver/config/$HACK.xml \
		     >> debian/$PACKAGE.install
	fi
	if [ -e debian/tmp/usr/share/applications/screensavers/$HACK.desktop ]
	then
		echo usr/share/applications/screensavers/$HACK.desktop \
		     >> debian/$PACKAGE.install
	fi
done < debian/split-hacks.config
exit 0
