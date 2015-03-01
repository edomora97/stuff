#!/bin/bash

# 720p 480p
quality=720p

# get the parameters
# -p PATH -> [ruby git javascript html-css ios electives]
# -q QUALITY
while getopts p:q: opts; do
   case ${opts} in
      p) path=${OPTARG} ;;
      q) quality=${OPTARG} ;;
   esac
done

if [ ! $path ]; then
	echo "Usage: $0 -p PATH [-q QUALITY]"
	exit 1
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
	if [ $count > 0 ]; then
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
		url=$(wget --load-cookies=cookies.txt https://www.codeschool.com/screencasts/$episode -O - 2>/dev/null | \
			egrep -o "http://projector.codeschool.com/videos/[^'\"]+" | \
			sed 's/\&amp;/\&/g' | \
			grep $quality | \
			head -n1)
		# write the title and the url in the $path_urls.txt file
		# title|url
		echo "$episode|$url" >> ${path}_urls.txt
	done < ${path}_pages.txt
else
	# don't overwrite the $path_urls.txt file
	echo "${path}_urls.txt already exists. Try removing it to regenerate it"
fi

# FOURTH: prepare to download the episodes, create the folder and count the episodes
mkdir -p videos/$path
count=$(cat ${path}_urls.txt | wc -l)
i=1

# FIFTH: download each episode and put them in the videos folder
while read line
do
	# split the line in title|url
	name=$(echo $line | cut -d"|" -f 1)
	url=$(echo $line | cut -d"|" -f 2)

	echo ""
	echo ""
	echo " --> $i/$count <-- Downloading videos/$path/$name.mp4"
	echo ""
	# if the video was already downloaded (completly or partially), skip!
	if [ ! -f "videos/$path/$name.mp4" ]; then
		curl -L "$url" -o "videos/$path/$name.mp4"
	else
		echo "Skipped!"
	fi
	i=$((i+1))
done < ${path}_urls.txt

# SIXTH: DONE!
