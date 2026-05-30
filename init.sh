#!/bin/bash

# Move os scripts para /usr/local/bin/
path_scripts="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/Scripts/*"
path_move=/usr/local/bin/

for file in "$path_scripts"; do
    sudo cp $file $path_move
done
