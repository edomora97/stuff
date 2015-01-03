#!/bin/bash

# for each episode
for file in `cat input.txt`; do
    echo $file
    # download the data
    ruby download.rb $file
done
