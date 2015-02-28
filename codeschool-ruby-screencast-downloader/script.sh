#!/bin/bash

# FIRST: create the cookies.txt file with the cookies from a codeschool page.
# You must be enrolled to download pro content
# You should use 'cookie.txt export' for chrome! and use the wget format

# SECOND: load the index page with all the screencast about 'ruby'
# search all the /screencasts/ url and tail off the unwanted ones
if [ ! -f pages.txt ]; then
	curl -L https://www.codeschool.com/screencasts/all\?filters%5Bpath%5D\=ruby 2>/dev/null | \
		egrep "/screencasts/[^\"]+" -o | \
		head -n -2 | \
		tail -n +9 > pages.txt
else
	echo "pages.txt already exists. Try removing it to regenerate it"
fi

# THIRD: noop!

# FOURTH: foreach screencast load the page and search for the download url,
# the episode name is the screencast url...
if [ ! -f urls.txt ]; then
	echo -n "" > urls.txt
	while read path
	do
		echo $path
		url=$(wget --load-cookies=cookies.txt https://www.codeschool.com$path -O - 2>/dev/null | \
			egrep -o "http://projector.codeschool.com/videos/[^'\"]+" | \
			sed 's/\&amp;/\&/g' | \
			head -n1)
		name=$(echo $path | cut -b 14-)
		echo "$name | $url" >> urls.txt
	done < pages.txt
else
	echo "urls.txt already exists. Try removing it to regenerate it"
fi

# FIFITH: prepare to download the episodes
mkdir -p videos
count=$(cat urls.txt | wc -l)
i=1

# SIXTH: download each episode and put them in the videos folder
while read line
do
	name=$(echo $line | cut -d"|" -f 1 | tr -d '[[:space:]]')
	url=$(echo $line | cut -d"|" -f 2 | tr -d '[[:space:]]')

	echo ""
	echo ""
	echo " --> $i/$count <-- Downloading videos/$name.mp4"
	echo ""
	curl -L "$url" -o "videos/$name.mp4"
	i=$((i+1))
done < urls.txt

# SEVENTH: DONE!
