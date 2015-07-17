#!/bin/bash

# NOTE: requires ImageMagick and libcaca to be installed

if [ -z "$WUNDERGROUND_API_KEY" ]; then
    echo "Please export WUNDERGROUND_API_KEY variable"
    exit -1
fi

if [[ -z "$1" ]] || [[ -z "$2" ]]
then
    echo "Usage weather.sh City State"
    echo "ex: weather.sh San_Francisco CA"
    exit -1
fi

# make sure we have the programs we need
command -v convert >/dev/null 2>&1 || { echo >&2 "convert command is required, but ImageMagick is not installed.  Aborting."; exit 1; }
command -v img2txt >/dev/null 2>&1 || { echo >&2 "img2txt command is required, but libcaca is not installed.  Aborting."; exit 1; }
command -v jq >/dev/null 2>&1 || { echo >&2 "jq command is required, but jq is not installed.  Aborting."; exit 1; }

#Set variables
KEY=$WUNDERGROUND_API_KEY
STATE=$2
CITY=$1
DOWNLOAD_DIR=/tmp/weather/

WEATHER_GIF="http://api.wunderground.com/api/${KEY}/animatedradar/q/${STATE}/${CITY}.gif?newmaps=1&timelabel=1&timelabel.y=10&num=5&delay=50"
WEATHER_CURRENT="http://api.wunderground.com/api/${KEY}/conditions/q/${STATE}/${CITY}.json"
WEATHER_FORECAST="http://api.wunderground.com/api/${KEY}/forecast/q/${STATE}/${CITY}.json"

COUNTER=0

#check for  download directory
if [ ! -d "$DOWNLOAD_DIR" ]; then
  mkdir -p $DOWNLOAD_DIR
fi

#remove old files
rm  $DOWNLOAD_DIR/*

#get weather gif
wget -O "${DOWNLOAD_DIR}map.gif" -q "${WEATHER_GIF}" &> /dev/null

# get weather json
cur="${DOWNLOAD_DIR}current.json"
wget -O - -q "${WEATHER_CURRENT}" | jq '.current_observation' > $cur

forc="${DOWNLOAD_DIR}forecast.json"
wget -O - -q "${WEATHER_FORECAST}" | jq '.forecast.txt_forecast' > $forc

#extract gif to png
convert -coalesce "${DOWNLOAD_DIR}/map.gif" "${DOWNLOAD_DIR}/map.png"

#convert images to text
for i in $DOWNLOAD_DIR/map-*; do
   img2txt -f utf8 -W 100 -H 30 $i > $i.txt
done

# get current conditions as vars
temp=$(cat $cur | jq '.temp_f')
feelslike=$(cat $cur | jq '.feelslike_f')
humidity=$(cat $cur | jq '.relative_humidity')
wind=$(cat $cur | jq '.wind_string')
link=$(cat $cur | jq '.forecast_url')

# get forecast
forecast_str=$(cat $forc | jq '.forecastday[0].fcttext')

# clear the screen before we start
clear

#display images and text conditions
while [ $COUNTER -lt 5 ] ; do
  for i in $DOWNLOAD_DIR/map-*.txt; do
     printf '\033[1;1H' # move cursor back to 1st row
     cat $i

     echo
     echo "Weather for ${CITY}, ${STATE}"
     echo
     printf 'Temp:\t\t%s\n' $temp
     printf 'Feels Like:\t%s\n' $feelslike
     printf 'Wind:\t\t%s\n' "$wind"
     printf 'Humidity:\t%s\n' $humidity
     echo
     echo "Forecast $forecast_str"
     echo
     echo "URL: $link"

     sleep 0.5
  done
  let COUNTER=COUNTER+1
done
