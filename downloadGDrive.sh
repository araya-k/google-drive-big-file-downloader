#!/bin/bash

white="\033[0;37m";
greenBold="\033[1;32m";
yellowIntense="\033[0;93m";
reset="\033[0m";

clear;
echo -e "${white}What is the full URL of the Google Drive file that you wish to download?${reset}";
echo -e "${greenBold}NOTE${reset}${white}:Only file larger than ${reset}${greenBold}100MB${reset}${white} can be downloaded by this script.${reset}";

echo -e "${greenBold}";
read query;
echo -e "${reset}";

echo -e "${white}Checking URL validity ...${reset}";
echo -e "${yellowIntense}";
FILEID="$(echo $query | sed -n 's#.*\https\:\/\/drive\.google\.com/file/d/\([^.]*\)\/view.*#\1#;p')";
echo -e "${reset}";

if [ "$FILEID" != "$query" ]; then
  echo -e "${white}URL is valid. The file ID is ${reset}${greenBold}$FILEID${reset}";

  echo -e "${white}Preparing the URL for download ...${reset}";
  echo -e "${yellowIntense}";
  FILENAME="$(wget -q --show-progress -O - "https://drive.google.com/file/d/$FILEID/view" | sed -n -e 's!.*<title>\(.*\)\ \-\ Google\ Drive</title>.*!\1!p')";
  CONFIRM_CODE=$(wget -q --show-progress --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate "https://docs.google.com/uc?export=download&id=$FILEID" -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p');
  echo -e "${reset}";

  echo -e "${white}The file ${greenBold}$FILENAME ${white}is now ready to be downloaded.";
  
  echo -e "${white}Starting the download process of ${reset}${greenBold}$FILENAME${reset}${white} now ...${reset}";
  echo -e "${yellowIntense}";  
  wget -q --show-progress --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$CONFIRM_CODE&id=$FILEID" -c -O "$FILENAME" && rm -rf /tmp/cookies.txt;
  echo -e "${reset}";

  if [ -f "$FILENAME" ]; then
    echo -e "${white}The file ${reset}${greenBold}$FILENAME${reset}${white} has been downloaded.${reset}";
  else
    echo -e "${white}The download attempt for file ${reset}${greenBold}$FILENAME${reset}${white} failed.${reset}";
  fi
else
  echo -e "${white}URL is not valid! Example of valid URL: ${reset}${greenBold}https://drive.google.com/file/d/xxxxxxx/view${reset}";
fi