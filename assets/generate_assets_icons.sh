#!/bin/bash

resize_images() {
    local input_folder="$1"
    local output_size="$2" # Expected format WIDTHxHEIGHT, e.g., 50x50
    local output_folder="$3"

    # Find all .png images that end with '2.png' and resize them.
    find "$input_folder" -type f -name "*2.png" | while read -r infile; do
        local relative_path="${infile#$input_folder/}"
        relative_path="${relative_path//2.png/icon.png}" # Replace '2.png' with 'icon.png'
        local outfile="$output_folder/$relative_path"
        local outdir=$(dirname "$outfile")
        mkdir -p "$outdir"
        convert "$infile" -resize "$output_size" "$outfile"
    done
}

mkdir -p icons

directories=("abs" "back" "biceps" "chest" "legs" "shoulder" "triceps")
for dir in "${directories[@]}"; do
    resize_images "$dir" "50x50" "icons/$dir"
done
