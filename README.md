# Terminal-Weather-Radar

Downloads a gif of a weather radar from Wunderground API, converts it to text and displays in the terminal.

Environment var WUNDERGROUND_API_KEY should be exported and a valid key. Key can be obtained from www.wundergroud.com

Set DOWNLOAD_DIR to the location you want to download the images. (default /tmp/weather/)

Usage: ./weather.sh City State
ex: ./weather.sh San_Francisco CA
