#!/bin/bash 


# Help you auto relink proxy provider folder

# Enumerate all .yaml files in the current directory
for file_path in /etc/openclash/config/*.yaml; do
    if [ -e "$file_path" ]; then  # Check if file exists to avoid issues when no .yaml files are found
        short_file_name=$(basename "$file_path")
        linkage_path="/etc/openclash/proxy_provider/${short_file_name}"
        
        if [ ! -e "$linkage_path" ]; then
            ln -s "$file_path" "$linkage_path"
        fi

    else
        echo "No .yaml files found in the current directory."
        break
    fi
done