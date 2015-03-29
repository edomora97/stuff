#!/bin/bash

if [ $# -le 3 ]; then
	echo "Usage $0 server remote_folder remote_addr local_folder [options]"
	echo "  Ex"
	echo "  $0 example.com /tmp/foo/bar /files/foo/bar . 16"
	echo "    will download all the files from the server 'example.com'"
	echo "    located in /tmp/foo/bar folder in the server"
	echo "    accessible via http at http://example.com/files/foo/bar"
	echo "    saving them in this folder ( . )"
	echo "    and using 16 parallel connections"
	echo "  PARAMETERS:"
	echo "   - Server: Must be accessible via SSH and HTTP"
	echo "   - Remote Folder: Must be accessible for the current user"
	echo "   - Remote Address: Must start with / and NOT end with /"
	echo "   - Local Folder: Must exist (?)"
	echo "   - Options: will be passed to aria2c"
	exit 1
fi

# get the parameters
Server=$1
RemoteFolder=$2
RemoteAddr=$3
LocalFolder=$4

# remove the parameters
shift; shift; shift; shift

Parts=16

# retrive the file list
Files=$(ssh $Server ls $RemoteFolder)

echo " ==== CONNECTED TO THE SERVER ==== "
echo " ---- File to download        ---- "
echo $Files

for file in $Files
do
	url=http://$Server$RemoteAddr/$file
	echo ""
	echo " ======= DOWNLOADING $file"
	echo "     from: $url"
	echo ""

	aria2c -s $Parts -x $Parts --dir=$LocalFolder --allow-overwrite=false --auto-file-renaming=false $url $@
	RET=$?
	if [ $RET -gt 0 ]; then
		echo "ERROR"
		xmessage -timeout 15 "An error occurred downloading $file from $url. The exit status was $RET" &
	else
		xmessage -timeout 15 "Download of $file from $url is completed!" &
	fi
done
