# Yet-Another-WatchFace
Watch Face application for Garmin Fenix 5[X][Plus], D2, Forerunner 245[M]/645[M]/935/945, Mk1, MARQ1 smartwatch

Watch Face application for Garmin smartwatches: 
<pre>
    D2 Charlie, D2 Delta, D2 Delta PX, D2 Delta S, 
    Darth Vader, 
    Descent Mk1, 
    First Avenger, 
    Forerunner 245, Forerunner 245 Music, 645, 645 Music, 935, 945, 
    fēnix 5, quatix 5, fēnix 5 Plus, fēnix 5S Plus, fēnix 5X, tactix Charlie, fēnix 5X Plus, 
    fēnix® 6, fēnix® 6 Pro, fēnix® 6 Sapphire, 
    fēnix® 6S, fēnix® 6S Pro, fēnix® 6S Sapphire, 
    fēnix® 6X Pro, fēnix® 6X Sapphire, fēnix® 6X Pro Solar, tactix® Delta Sapphire, 
    MARQ Adventurer, MARQ Athlete, MARQ Aviator, MARQ Captain, MARQ Commander, MARQ Driver, MARQ Expedition, 
    vivoactive 4 
</pre>
## Features
- Time (this is a watch face, after all) 
- Current City Name, based on GPS. You have to get GPS coordinates to update the city if the location has been changed 
- Current Date and Week Day
- Battery Level
- Actual Weather in current location, Temperature (C|F), Perception probability and Wind(kn|m/s)
- Current Time in one addition timezone (DST will be calculated automatically)
- Actual Currency Exchange Rate, between two out of 47 currencies. Updates once in 60 min if internet connection is available
- Pulse
- Distance (km, miles, steps)
- Floors climbed

Configure all the watch face options via the Garmin Connect mobile app:
Open Garmin Connect Mobile. Touch More, Garmin Devices, (your device), Connect IQ Apps, Watch Faces, (select YA-WatchFace), Settings.

## Screenshots
<img src="https://raw.githubusercontent.com/Laverlin/Yet-Another-WatchFace/master/resources/screens/WatchScreen1.png" height="300px" /> <img src="https://raw.githubusercontent.com/Laverlin/Yet-Another-WatchFace/master/resources/screens/WatchScreen2.png" height="300px" />  <img src="https://raw.githubusercontent.com/Laverlin/Yet-Another-WatchFace/master/resources/screens/WatchScreen3.png" height="300px" />



# Changelog

## version latest
- add moon phases and moon zodiac
- change bottom line settings

### version 0.9.212 
- add various date formats
- minor improvements: add mph to the wind speed, add orange color

### version 0.9.189
- add OpenWeather provider as an option
- improve Fenix 6X layout

### version 0.9.175

- now available on MARQ Commander/Adventurer, Darth Vaider
- now available on Viviactive 4
- now available on Fenix 6*, Fenix 6S*, Fenix 6X*

### version 0.9.152
- remove diacritics from city names
- fixed issue with floors on FX245* devices
- add an indicator of unsuccessful web request attempt (red bluetooth sign means failed request)
- fixed issue with null location

### version  0.9.136
- optimize memory footprint
- currency exchange provider has been changed (reduce the number of supported currencies)

### version 0.9.127
- add sunrise/sunset info

### version 0.9.120
- add km/h as wind speed
- option to center city name and alarm/message info
- altitude in meters/feet

### version 0.9.112
- the count of notifications and message  at the bottom line
- add support D2, Forerunner 245[M]/645[M]/935/945, Mk1, MARQ1
- fix issue with updated exchange api

### version 0.9.97 
- red battery level if it less 20%
- add calories and altimeter
- add combined steps and floors  
- fix minor issues

### version 0.9.90
- the count of notifications and messages has been added
- fix round numbers displaying issue

### version 0.9.87
- add floors climbed 
- add fields configuration 
- add support Forerunner 935 

### version 0.9.61 
- Option to disable display seconds has been added
- AM/PM has support has been added
- Too long city/country name issue fixed
- TWD currency has been added
- battery consumption when pulse is displayed has been optimized 
