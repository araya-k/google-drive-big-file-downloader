#!/bin/bash

load="\033[0;93m"
url="\033[1;32m"
msg="\033[0;37m"

clear;
echo "${msg}What is the full URL of the Google Drive file that you wish to download?"
echo "${url}NOTE${msg}:Only file larger than ${url}100MB${msg} can be downloaded by this script.${url}";
read query;

echo "\n${msg}Checking URL validity ...${load}";
FILEID="$(echo $query | sed -n 's#.*\https\:\/\/drive\.google\.com/file/d/\([^.]*\)\/view.*#\1#;p')";

if [ "$FILEID" != "$query" ]; then
  echo "${msg}URL is valid. The file ID is ${url}$FILEID\n";

  echo "${msg}Preparing the URL for download ...${load}";
  FILENAME="$(wget -q --show-progress -O - "https://drive.google.com/file/d/$FILEID/view" | sed -n -e 's!.*<title>\(.*\)\ \-\ Google\ Drive</title>.*!\1!p')";
  CONFIRM_CODE=$(wget -q --show-progress --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate "https://docs.google.com/uc?export=download&id=$FILEID" -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p');
  
  echo "${msg}The file ${url}$FILENAME ${msg}is now ready to be downloaded.\n";
  
  echo "${msg}Starting the download process of ${url}$FILENAME now ...${load}";  
  wget -q --show-progress --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$CONFIRM_CODE&id=$FILEID" -c -O "$FILENAME" && rm -rf /tmp/cookies.txt;

  if [ -f "$FILENAME" ]; then
    echo "${msg}The file ${url}$FILENAME ${msg}has been downloaded.";
    return 0;
  else
    echo "${msg}The download attempt for file ${url}$FILENAME ${msg}failed.";
    return 1;
  fi
else
  echo "${msg}URL is not valid! Example of valid URL: ${url}https://drive.google.com/file/d/xxxxxxx/view";
  return 1;
fi