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

starttime=$(perl -MTime::HiRes -e 'printf("%.0f\n",Time::HiRes::time()*1000)')

#start_time=`date +%s%N`
lastbuildfile="$SRCROOT/lastbuild.txt"
lastbuildfiledate=$(stat -f "%Sm" -t "%Y%m%d%H%M%S" "$lastbuildfile")

# ezt csak azert teszem bele, hogy barmikor ujra forditani az egesz projektet
buildagain=true

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
		if $buildagain || [[ $lastbuildsourcedate -gt $7 ]]; then
			targetname="$1/$filename.nfo"

			echo "target: $targetname"

			eval "$nsbtool" "$afile" "$targetname" 2>&1
			aret_code=$?
			if [[ $aret_code -gt $ret_code ]]; then
				ret_code=$aret_code
			fi
			echo "ret_code: $ret_code"
		fi
	done < <(find "$4" -name "*$elotag*nsb" -type f -mindepth 1 -maxdepth 1)

	if [[ $ret_code -eq 0 ]]; then
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

eval creategrf "$1" "$SRCROOT" "$SRCROOT/sprites" "$SRCROOT/nsb" "hsst" "hungarian_stations_teszt" "$lastbuildfiledate" "/Users/idioty/Documents/OpenTTD/newgrf" 2>&1
aret_code=$?
if [[ $aret_code -gt $ret_code ]]; then
	ret_code=$aret_code
fi

if [[ $ret_code -le 1 ]]; then
	echo "barmi" > "$lastbuildfile"
fi

endtime=$(perl -MTime::HiRes -e 'printf("%.0f\n",Time::HiRes::time()*1000)')
echo execution time was `expr $endtime - $starttime` ms.

exit $ret_code
#IFS=$SAVEIFS