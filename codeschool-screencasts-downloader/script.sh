#!/bin/bash

function download {
	aria2c -s16 -x16 -k1M $1 -o $2 2>/dev/null
}

quality=auto

# get the parameters
# -p PATH -> [ruby git javascript html-css ios electives]
# -q QUALITY -> [auto 720p 480p]
# -f -> fake
while getopts p:q:f opts; do
   case ${opts} in
      p) path=${OPTARG} ;;
      q) quality=${OPTARG} ;;
      f) fake=true
   esac
done

if [ ! $path ]; then
	echo "Usage: $0 -p PATH [-q QUALITY] [-f]"
	exit 1
fi
if [[ $quality == "auto" ]]; then
	quality="720p|480p"
fi

# FIRST: create the cookies.txt file with the cookies from a codeschool page.
# You must be enrolled to download pro content
# You should use 'cookie.txt export' for chrome! and use the wget format

# SECOND: load the index page with all the screencast about '$path'
# search all the /screencasts/ url and tail off the unwanted ones
if [ ! -f ${path}_pages.txt ]; then
	# get all episodes from the index
	episodes=$(curl -L https://www.codeschool.com/screencasts/all\?filters%5Bpath%5D\=$path 2>/dev/null | \
		egrep "/screencasts/[^\"]+" -o)

	# foreach episode check if it is a real episode
	for ep in $episodes; do
		# remove the /screencasts/ prefix
		ep=$(echo $ep | cut -b 14-)
		# the episode names can only have letters, numbers and dashes
		if [[ $ep =~ ^[\-a-zA-Z0-9]+$ ]]; then
			echo $ep >> ${path}_pages.txt
			echo "Download \"$ep\""
			there_are_episodes=true
		else
			echo "Skipped $ep"
		fi
	done
else
	# if the file $path_pages.txt already exists, don't reload it
	echo "${path}_pages.txt already exists. Try removing it to regenerate it"
	count=$(cat ${path}_pages.txt | wc -l)
	if [[ $count > 0 ]]; then
		there_are_episodes=true
	fi
fi

if [ ! $there_are_episodes ]; then
	echo "No screencasts found for the $path path"
	exit 1
fi

# THIRD: foreach screencast load the page and search for the download url,
# the episode name is the screencast url...
if [ ! -f ${path}_urls.txt ]; then
	while read episode
	do
		echo "Fetching url of $episode"
		# load the page of the episode using the specified cookies and search
		# the download link.
		# Then find&replace the &amp; with &
		# Then use the link of the specified quality
		# And select only the first link
		urls=$(wget --load-cookies=cookies.txt https://www.codeschool.com/screencasts/$episode -O - 2>/dev/null | \
			egrep -o "http://projector.codeschool.com/videos/[^'\"]+" | \
			sed 's/\&amp;/\&/g' | \
			head -n 2 | \
			egrep $quality)

		first=$(echo $urls | cut -d" " -f 1)
		second=$(echo $urls | cut -d" " -f 2)

		# write the title and the url in the $path_urls.txt file
		# title|url
		echo "$episode|$first|$second" >> ${path}_urls.txt
	done < ${path}_pages.txt
else
	# don't overwrite the $path_urls.txt file
	echo "${path}_urls.txt already exists. Try removing it to regenerate it"
fi

if [ ! $fake ]; then

# FOURTH: prepare to download the episodes, create the folder and count the episodes
mkdir -p videos/$path
count=$(cat ${path}_urls.txt | wc -l)
i=1

# FIFTH: download each episode and put them in the videos folder
while read line
do
	# split the line in title|url1|url2
	name=$(echo $line | cut -d"|" -f 1)
	first=$(echo $line | cut -d"|" -f 2)
	second=$(echo $line | cut -d"|" -f 3)
	output="videos/$path/$name.mp4"

	echo ""
	echo ""
	echo " --> $i/$count <-- Downloading $output"
	echo ""
	# try to downlaod the first version, if there is an error, try the second
	download $first $output || download $second $output
	i=$((i+1))
done < ${path}_urls.txt

else
	echo "The -f fake option prevented to download the files"
fi # !fake

# SIXTH: DONE!
