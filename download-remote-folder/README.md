# Download Remote Folder

This script uses ssh and aria2 to download a folder from a remote server.

The SSH is used to fetch the list of files to download.
The HTTP is used to download the files using parallels connections.

## Usage
```
./download-remote-folder.sh server remote_folder remote_addr local_folder [options]

Example:
./download-remote-folder.sh example.com /tmp/foo/bar /files/bar ~/Desktop

```

In this example the files under /tmp/foo/bar are downloaded from http://example.com/files/bar and stored in ~/Desktop.

By default this script uses 16 parallel connections and uses the command find to fetch the file list recursively.
