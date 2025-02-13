#!/bin/bash

set -e 

contributionPath="./data/contribution"
srcFiles=("./data/"*.pak "./data/"*.sig)
pathFile="./path.txt"
vngFiles=("VNGLogo-WindowsClient.sig" "VNGLogo-WindowsClient.pak")

function ContributionPrint {
    local path="$1"
    if [[ ! -f "$path" ]]; then
        echo "Introduction file not found"
        exit 1
    fi

    cat "$path"
    echo "Do you wish to continue? (Y/N - Y is default, auto-continue in 5 seconds)"
    
    read -t 5 -n 1 signal
    if [[ "$signal" == "N" || "$signal" == "n" ]]; then
        echo "Thank you for using the script."
        exit 0
    fi
}

function ValidatePaths {
    local paths=("$@")
    for path in "${paths[@]}"; do
        if [[ ! -e "$path" ]]; then
            echo "Data is missing: $path. Please download the zip again."
            exit 1
        fi
    done
}

function GetDestinationPath {
    if [[ ! -f "$pathFile" ]]; then
        echo "Path file not found"
        exit 1
    fi

    destinationPath=$(cat "$pathFile" | xargs)
    if [[ ! -d "$destinationPath" ]]; then
        echo "Destination path not found: $destinationPath. Please check the path.txt file."
        exit 1
    fi
    echo "$destinationPath"
}

function CopyFiles {
    local srcFiles=("${!1}")
    local destinationPath="$2"
    cp -f "${srcFiles[@]}" "$destinationPath"
    echo "Files copied successfully."
}

function RemoveFiles {
    local destinationPath="$1"
    local files=("${!2}")
    for file in "${files[@]}"; do
        filePath="$destinationPath/$file"
        if [[ -f "$filePath" ]]; then
            rm -f "$filePath"
            echo "Removed $file successfully."
        else
            echo "File $file not found, skipping removal."
        fi
    done
}

function Main {
    ContributionPrint "$contributionPath"
    ValidatePaths "${srcFiles[@]}"
    destinationPath=$(GetDestinationPath)

    CopyFiles srcFiles[@] "$destinationPath"
    RemoveFiles "$destinationPath" vngFiles[@]

    echo "Script executed successfully. Exiting..."
    exit 0
}

Main
