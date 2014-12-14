#!/bin/bash

#  build.sh
#  allomasgrf
#
#  Created by Kiss Ferenc on 2014.02.06..
#  Copyright (c) 2014 Kiss Ferenc. All rights reserved.


#echo "az: $SRCROOT"

#SAVEIFS=$IFS
#IFS=$(echo -en "\n\b")




# uj nsb programommal elkeszitem az uj fajolkat

nsbmap="/Users/idioty/Applications/nsb"
cd "$nsbmap"
nsbtool="$nsbmap/nsb.sh"

sourceext="nsb"

lastbuildfile="$SRCROOT/lastbuild.txt"
lastbuildfiledate=$(stat -f "%Sm" -t "%Y%m%d%H%M%S" "$lastbuildfile")

#while read -r line
#do
#	echo "line: "$line
#done < <($nsbtool "/Users/idioty/Github/openttd/allomasgrf/nsb/01_nyugati.txt" "/Users/idioty/Github/openttd/allomasgrf/sprites/01_nyugati.nfo")
while read -r afile
do
#for afile in "$@"; do
#	sourcelength=${#sourceext}
#	(($sourcelength))
	baseafile=$(basename $afile)
#	fileext="${afile##*.}"
	filename="${baseafile%.*}"
#	sourcename="/Users/idioty/Github/openttd/allomasgrf/nsb/$afile.$sourceext"
	lastbuildsourcedate=$(stat -f "%Sm" -t "%Y%m%d%H%M%S" "$afile")
	if [[ $lastbuildsourcedate -gt $lastbuildfiledate ]]; then
		targetname="$1/$filename.nfo"

		while read -r line; do
			echo "$line"
		done < <($nsbtool "$afile" "$targetname")
	fi
#done
done < <(find "$SRCROOT/nsb" -name "*nsb" -type f -mindepth 1 -maxdepth 1)

#exit 0

cd $SRCROOT

# nfo osszrekasa, ellenorzese
sajatgrfname="hungarian_stations"
sajatgrftestname=$sajatgrfname"_test"
sajatnfoname=$sajatgrfname".nfo"
sajatnfo="sprites/"$sajatnfoname
sajatnfotestname=$sajatgrftestname".nfo"
sajatnfotest="sprites/"$sajatnfotestname

if [[ -f "$sajatnfotest" ]]; then
	rm "$sajatnfotest"
fi

while read -r line
do
	echo "line: "$line
	if [[ ! "$line" = "$sajatnfo" ]] && [[ ! "$line" = "$sajatnfotest" ]]; then
		cat "$line" >> "$sajatnfotest"
	fi
done < <(find sprites -name "*nfo" -type f -mindepth 1 -maxdepth 1)

eval "nforenum $sajatnfotestname 2>&1"
ret_code=$?
if [ $ret_code == 0 ]; then
	echo "NFRRENUM sikeresen lefutott"
	grftestneve=$sajatgrftestname".grf"
	eval "grfcodec -e $grftestneve 2>&1"
	ret_code=$?
	if [ $ret_code == 0 ]; then
		echo "GRFMAKER sikeresen lefutott"

		if [[ -f /Users/idioty/Documents/OpenTTD/newgrf/"$grftestneve" ]]; then
			rm /Users/idioty/Documents/OpenTTD/newgrf/"$grftestneve"
		fi
		cp "$grftestneve" /Users/idioty/Documents/OpenTTD/newgrf/


		# most elkeszult a tesztverzio ami nekem fut a gepemen, es most megcsinaljuk a teszt nelkuli kiadast
		# egesz teszt kihagyasa
		exlude="! -name 99_teszt.nfo"

		# egesz nyugati kihagyasa
		exlude=$exlude" ! -name 1*.nfo"

		if [[ -f "$sajatnfo" ]]; then
			rm "$sajatnfo"
		fi

		while read -r line
		do
			if [[ ! "$line" = "$sajatnfo" ]] && [[ ! "$line" = "$sajatnfotest" ]]; then
				cat "$line" >> "$sajatnfo"
			fi
		done < <(find sprites -name "*nfo" ! -name "$sajatnfotest" ! -name "sajatnfo" $exlude -type f -mindepth 1 -maxdepth 1)

		eval "nforenum $sajatnfoname 2>&1"
		ret_code=$?
		if [ $ret_code == 0 ]; then
			grfneve=$sajatgrfname".grf"
			eval "grfcodec -e $grfneve 2>&1"
			ret_code=$?
			if [ $ret_code == 0 ]; then
				echo "GRFMAKER sikeresen lefutott a release grffel"
			else
				echo "Hiba van a GRFMAKERREL a release grf elkészítésekor"
			fi
		else
			echo "Hiba van az NFORENUMMAL a release nfo elkészítésekor"
		fi
	else
		echo "Hiba van a GRFMAKERREL"
	fi
else
	echo "Hiba van az NFORENUMMAL"
fi

echo "barmi" > "$lastbuildfile"

exit $ret_code
#IFS=$SAVEIFS