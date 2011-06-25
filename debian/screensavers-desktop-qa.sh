#!/bin/sh
# Check our desktop files and compare them to upstream xml files
# Or, provided an xml file as argument, generate a desktop file
# 2008 Tormod Volden

# Some xml files are for external programs or hacks that are not built
# we do not ship desktop files for those
EXTERNALS="\
 cosmos \
 dnalogo \
 electricsheep \
 fireflies \
 goban \
 rdbomb \
 sphereeversion \
 xaos \
 xdaliclock \
 xmountains \
 xplanet \
 xsnow \
 xteevee \
"

# Poor man's xml parser "can i haz xml purrser"
get_xml_option () {
	file=$1
	tag=$2
	option=$3

	< $file sed -n '/\<'$tag' /s@.* '$option'="\([^"]*\)".*@\1@p'
}

get_xml_entity () {
	file=$1
	tag=$2

	< $file sed -e ':a; /<'$tag'/N;s/\n/ /; ta' |
		sed -ne 's/.*<'$tag'> *\(.*\)<\/'$tag'>.*/\1/p'
}

extract_entries () {
  XML=$1

  XMLNAME=`get_xml_option $XML screensaver name`
  XMLARG=`get_xml_option $XML command arg | sed ':a; N; s/\n/ /; ta'` 
  XMLEXE="$XMLNAME $XMLARG"

  XMLLABEL=`get_xml_option $XML screensaver _label`

  # delete trailing spaces and years
  XMLDES=`get_xml_entity $XML _description |
	sed 's/   */ /g; s/[;,.] [0-9;,. ]*$/./'`

  # Only get first part of first paragraph
  SHORTDES=`echo $XMLDES | sed 's/[.:!(].*/./'`
}


# If called with an argument, create desktop file contents from given xml file
if [ -n "$1" ]; then
	
	extract_entries $1
	cat <<- EODESKTOP

		[Desktop Entry]
		Name=$XMLLABEL
		Exec=/usr/lib/xscreensaver/$XMLEXE
		TryExec=/usr/lib/xscreensaver/$XMLNAME
		Comment=$XMLDES
	EODESKTOP
	exit 0
fi



for XML in hacks/config/*.xml; do
  NAME=`basename $XML .xml`
  DSK=debian/screensavers-desktop-files/${NAME}.desktop

  if echo $EXTERNALS | grep -wq $NAME; then
	if [ -f $DSK ]; then
		echo " external $NAME has a desktop file"
	fi
	continue
  fi

  if [ ! -f hacks/${NAME}.c  ] &&
     [ ! -f hacks/glx/${NAME}.c ] &&
     [ ! -f hacks/${NAME} ]
  then
	echo " no c source or script file for $NAME"
  fi

  if [ ! -f hacks/${NAME}.man  ] &&
     [ ! -f hacks/glx/${NAME}.man ]
  then
	echo " no man page for $NAME"
  fi

  if [ ! -f $DSK ]; then
	echo " missing $DSK file"
	continue
  fi

  extract_entries $XML

  DSKEXE=`sed -n '/^Exec=/s@Exec=@@p' < $DSK`
  if [ x"$XMLEXE" = x ] ||
     [ x"$DSKEXE" = x ] ||
     [ x"$XMLEXE" != x"$DSKEXE" ]; then
	echo " exec not matching: $XMLEXE and $DSKEXE"
  fi

  DSKNAME=`sed -n '/^Name=/s@Name=@@p' < $DSK`
  if [ x"$XMLLABEL" = x ] ||
     [ x"$DSKNAME" = x ] ||
     [ x"$XMLLABEL" != x"$DSKNAME" ]; then
	echo " name not matching: $XMLLABEL and $DSKNAME"
  fi

  DSKTRY=`sed -n '/^TryExec=/s@TryExec=@@p' < $DSK`
  if [ x"$XMLNAME" = x ] ||
     [ x"$DSKTRY" = x ] ||
     [ x"$XMLNAME" != x"$DSKTRY" ]; then
	echo " tryexec name not matching: $XMLNAME and $DSKTRY"
  fi

  DSKDES=`sed -n '/^Comment=/s@Comment=@@p' < $DSK |
		sed 's/[;,.] [0-9;,. ]*$/./'`

#  if [ x"$XMLDES" = x ] ||
#     [ x"$DSKDES" = x ] ||
#     [ x"$XMLDES" != x"$DSKDES" ]; then
#	echo " description not matching on $NAME"
  if [ x"$XMLDES" = x ] || [ x"$DSKDES" = x ]; then
	echo " description missing on $NAME"
  fi

done
