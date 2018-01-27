#!/bin/bash
torrent_id=$1
torrent_name=$2
torrent_dir=$3
full_path="${torrent_dir}/${torrent_name}"
tmp_output_dir="/mnt/storage/tmp/$torrent_name"
tmp_output_ffmpeg_path="$tmp_output_dir/$torrent_name.mp4"
final_output_dir="/mnt/storage"

# Loop through all rar files and extract them
for file in $(find $full_path -type f -name '*.rar')
do
    unrar e -y $file
done

# Create temporary directory structure
mkdir -p $tmp_output_dir

# Convert all .mkv video files which are not named "sample" to mp4 with AC3 audio
for mkv_path in $(find $full_path -type f -name '*.mkv' | grep -v 'sample')
do
    # Remux with ffmpeg
    ffmpeg -i $mkv_path -metadata title="" -vcodec copy -acodec ac3 -b:a 640k $tmp_output_ffmpeg_path
done

# Copy all subtitles to tmp dir
for sub in $(find $full_path -type f -name '*.srt' | grep -v 'sample')
do
    cp $sub $tmp_output_dir
done

# Rename files/folders and move them to movies folder
filebot -script fn:amc --output "$final_output_dir" --action move --conflict skip -non-strict --log-file "/mnt/storage/amc.log" --def unsorted=y excludeList=".excludes" ut_dir="$tmp_output_dir" ut_kind="multi" ut_title="$torrent_name" ut_label=""