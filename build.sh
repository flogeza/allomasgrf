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



lastbuildfile="$SRCROOT/lastbuild.txt"
lastbuildfiledate=$(stat -f "%Sm" -t "%Y%m%d%H%M%S" "$lastbuildfile")

creategrf() {
	echo "********    $6    ********"

	elotag="$5"
	nsbmap="/Users/idioty/Applications/nsb"
	cd "$nsbmap"
	nsbtool="$nsbmap/nsb.sh"

	# nsb osszerakasa
	while read -r afile
	do
		baseafile=$(basename $afile)
		filename="${baseafile%.*}"
		lastbuildsourcedate=$(stat -f "%Sm" -t "%Y%m%d%H%M%S" "$afile")
		if [[ $lastbuildsourcedate -gt $7 ]]; then
			targetname="$1/$filename.nfo"

			echo "target: $targetname"

			while read -r line; do
				echo "$line"
			done < <("$nsbtool" "$afile" "$targetname")
		fi
	done < <(find "$4" -name "*$elotag*nsb" -type f -mindepth 1 -maxdepth 1)

	# nfo osszerakasa
	sajatnfo="$3/$6.nfo"

	if [[ -f "$sajatnfo" ]]; then
		rm "$sajatnfo"
	fi

	while read -r line
	do
		if [[ ! "$line" = "$sajatnfo" ]]; then
			cat "$line" >> "$sajatnfo"
		fi
	done < <(find "$3" -name "*$elotag*nfo" ! -name "sajatnfo" -type f -mindepth 1 -maxdepth 1)

	echo "sajatnfo: $sajatnfo"

	# nforenum es grf osszeallitasa

	cd "$2"
	sajatgrfname="$6"
	sajatnfoname="$sajatgrfname.nfo"

	eval "nforenum $sajatnfoname 2>&1"
	ret_code=$?
	if [ $ret_code == 0 ]; then
		echo "*** NFORNENUM *** sikeresen lefutott"
		grfneve=$sajatgrfname".grf"
		eval "grfcodec -e $grfneve 2>&1"
		ret_code=$?
		if [ $ret_code == 0 ]; then
			echo "*** GRFMAKER *** sikeresen lefutott"
			installfile="$8/grfneve"
			if [[ -f "$installfile" ]]; then
				rm "$installfile"
			fi
			cp "$grfneve" "$8/"
		else
			echo "Hiba van a *** GRFMAKERREL ***"
		fi
	else
		echo "Hiba van az *** NFORENUMMAL ***"
	fi

	return $ret_code
}

eval creategrf "$1" "$SRCROOT" "$SRCROOT/sprites" "$SRCROOT/nsb" "hss1" "hungarian_stations" "$lastbuildfiledate" "/Users/idioty/Documents/OpenTTD/newgrf" 2>&1
ret_code=$?

eval creategrf "$1" "$SRCROOT" "$SRCROOT/sprites" "$SRCROOT/nsb" "hss2" "hungarian_stations2" "$lastbuildfiledate" "/Users/idioty/Documents/OpenTTD/newgrf" 2>&1
aret_code=$?
if [[ $aret_code -gt $ret_code ]]; then
	ret_code=$aret_code
fi

eval creategrf "$1" "$SRCROOT" "$SRCROOT/sprites" "$SRCROOT/nsb" "hss3" "hungarian_stations3" "$lastbuildfiledate" "/Users/idioty/Documents/OpenTTD/newgrf" 2>&1
aret_code=$?
if [[ $aret_code -gt $ret_code ]]; then
	ret_code=$aret_code
fi




#eval creategrf "$1" "$SRCROOT" "$SRCROOT/sprites" "$SRCROOT/nsb" "hsst" "hungarian_stations_teszt" "$lastbuildfiledate" "/Users/idioty/Documents/OpenTTD/newgrf" 2>&1
#aret_code=$?
#if [[ $aret_code -gt $ret_code ]]; then
#	ret_code=$aret_code
#fi
#




#echo "barmi" > "$lastbuildfile"
##exit 0
#
#cd $SRCROOT
#
## nfo osszrekasa, ellenorzese
#sajatgrfname="hungarian_stations"
#sajatgrftestname=$sajatgrfname"_test"
#sajatnfoname=$sajatgrfname".nfo"
#sajatnfo="sprites/"$sajatnfoname
#sajatnfotestname=$sajatgrftestname".nfo"
#sajatnfotest="sprites/"$sajatnfotestname
#
#if [[ -f "$sajatnfotest" ]]; then
#	rm "$sajatnfotest"
#fi
#
#while read -r line
#do
#	echo "line: "$line
#	if [[ ! "$line" = "$sajatnfo" ]] && [[ ! "$line" = "$sajatnfotest" ]]; then
#		cat "$line" >> "$sajatnfotest"
#	fi
#done < <(find sprites -name "*nfo" -type f -mindepth 1 -maxdepth 1)
#
#eval "nforenum $sajatnfotestname 2>&1"
#ret_code=$?
#if [ $ret_code == 0 ]; then
#	echo "NFRRENUM sikeresen lefutott"
#	grftestneve=$sajatgrftestname".grf"
#	eval "grfcodec -e $grftestneve 2>&1"
#	ret_code=$?
#	if [ $ret_code == 0 ]; then
#		echo "GRFMAKER sikeresen lefutott"
#
#		if [[ -f /Users/idioty/Documents/OpenTTD/newgrf/"$grftestneve" ]]; then
#			rm /Users/idioty/Documents/OpenTTD/newgrf/"$grftestneve"
#		fi
#		cp "$grftestneve" /Users/idioty/Documents/OpenTTD/newgrf/
#
#
#		# most elkeszult a tesztverzio ami nekem fut a gepemen, es most megcsinaljuk a teszt nelkuli kiadast
#		# egesz teszt kihagyasa
#		exlude="! -name 99_teszt.nfo"
#
#		# egesz nyugati kihagyasa
#		exlude=$exlude" ! -name 1*.nfo"
#
#		if [[ -f "$sajatnfo" ]]; then
#			rm "$sajatnfo"
#		fi
#
#		while read -r line
#		do
#			if [[ ! "$line" = "$sajatnfo" ]] && [[ ! "$line" = "$sajatnfotest" ]]; then
#				cat "$line" >> "$sajatnfo"
#			fi
#		done < <(find sprites -name "*nfo" ! -name "$sajatnfotest" ! -name "sajatnfo" $exlude -type f -mindepth 1 -maxdepth 1)
#
#		eval "nforenum $sajatnfoname 2>&1"
#		ret_code=$?
#		if [ $ret_code == 0 ]; then
#			grfneve=$sajatgrfname".grf"
#			eval "grfcodec -e $grfneve 2>&1"
#			ret_code=$?
#			if [ $ret_code == 0 ]; then
#				echo "GRFMAKER sikeresen lefutott a release grffel"
#			else
#				echo "Hiba van a GRFMAKERREL a release grf elkészítésekor"
#			fi
#		else
#			echo "Hiba van az NFORENUMMAL a release nfo elkészítésekor"
#		fi
#	else
#		echo "Hiba van a GRFMAKERREL"
#	fi
#else
#	echo "Hiba van az NFORENUMMAL"
#fi
#
#echo "barmi" > "$lastbuildfile"

exit $ret_code
#IFS=$SAVEIFS