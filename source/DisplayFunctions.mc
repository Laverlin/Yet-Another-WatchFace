using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.Activity as Activity;


class DisplayFunctions
{
	hidden var _heartRate = 0;
	hidden var _heartRateText = "-- ";
	hidden var _ecHour = null;
	hidden var _eventTime = null;
	hidden var _gTimeNow;
	hidden var _dc;
	hidden var _fonts;
	hidden var _conditionIcons = Ui.loadResource(Rez.JsonData.conditionIcons);
	
	hidden var _methods = [
		:DisplayExtraTz, :DisplayExchangeRate, :DisplayDistance, :DisplayPulse, 
		:DisplayFloors, :DisplayMsgCount, :DisplayAlarmCount, :DisplayAltitude, 
		:DisplayCalories, :DisplayStepsNFloors, :DisplaySunEvent];
	
	function setTime(time)
	{
		_gTimeNow = time;
	}
	
	function setDc(dc, fonts)
	{
		_dc = dc;
		_fonts = fonts;
	}
	
	function LoadField3(layout)
    {
       	return new Lang.Method(self, _methods[Setting.GetField(3)]).invoke(layout);
    }
    
   	function LoadField4(layout)
    {
       	return new Lang.Method(self, _methods[Setting.GetField(4)]).invoke(layout);
    }
    
    function LoadField5(layout)
    {
       	return new Lang.Method(self, _methods[Setting.GetField(5)]).invoke(layout);
    }

    ///
    /// returns [day, month, DOW]
    ///
    function DisplayDate(layout)
    {
    	return [_gTimeNow.day.format("%02d"), _gTimeNow.month.toLower(), _gTimeNow.day_of_week.toLower()] ;
    }

    ///
    /// returns [Hour, Min]
    ///
    function DisplayTime(layout) 
    {
    	var deviceSettings = Sys.getDeviceSettings();
    	return [(deviceSettings != null && deviceSettings.is24Hour) 
        			? _gTimeNow.hour.format("%02d") 
        			: (_gTimeNow.hour % 12 == 0 ? 12 : _gTimeNow.hour % 12).format("%02d"),
        		_gTimeNow.min.format("%02d")];
    }  
       
    ///
    /// returns [pm|am]
    ///   
    function DisplayPmAm(layout)
    {
    	return [_gTimeNow.hour > 11 ? "pm" : "am"];
    }
    
    ///
    /// returns [seconds]
    ///
    function DisplaySeconds(layout)
    {
    	return [Sys.getClockTime().sec.format("%02d")];
    }
 
    ///
    /// returns [connection status]
    ///   
    function DisplayConnection(layout)
    {
    	layout["c"] = Setting.GetConError() ? [3] : [0];
    	var deviceSettings = Sys.getDeviceSettings();

    	return [(deviceSettings != null && deviceSettings.phoneConnected) ? "a" : "b"];
    }
    
    ///
    /// returns temperature and perception probability
    ///
    function DisplayTemp(layout)
    {
    	var weather = Setting.GetWeather();

    	if (weather == null || Setting.GetAuthError()) // no weather
        {
			var temp =  Setting.GetLastKnownLocation() == null 
						? "no GPS" 
						: (Setting.GetAuthError())
							? "auth error" 
							: (Setting.GetWeatherProvider() == 1 && (Setting.GetWeatherApiKey() == null || Setting.GetWeatherApiKey() == ""))
								? "no API key"
								: "loading...";
			return [temp, "", "", ""];
        }
        else
        {
        	var weatherPercent = Setting.GetWeatherProvider() == 1
        		? weather["precipitation"] 
        		: weather["humidity"];
        	weatherPercent = (weatherPercent != null ) ? weatherPercent : 0;
        	var temp = (Setting.GetTempSystem() == 1 ? weather["temp"] : weather["temp"] * 1.8 + 32)
				.format(weatherPercent > 99 ? "%d" : "%2.1f");
			
			return [temp, Setting.GetTempSystem() == 1 ? "c" : "f", weatherPercent.format("%2d"), "%"];
        }
    }
    
    function DisplayWind(layout)
    {
    	var weather = Setting.GetWeather(); 

    	if (weather == null || Setting.GetAuthError()) // no weather
        {
        	return ["", "", " "];
        }
        else
        {
        	var windMultiplier = [3.6, 1.94384, 1];
        	var windSystemLabel = ["k/h", "kn", "m/s"];
        	
        	return [(weather["wndSpeed"] * windMultiplier[Setting.GetWindSystem()]).format("%2.1f"),
        		windSystemLabel[Setting.GetWindSystem()],
        		(_conditionIcons[weather["condition"]] == null) 
        			? ""
        			: _conditionIcons[weather["condition"]]];
        }
    }
    
   	///
   	/// Return extra time-zone info
   	///
    function DisplayExtraTz(layout)
    {
    	var tzInfo = WatchData.GetTzTime(Time.now(), Setting.GetExtraTimeZone());
    	return [tzInfo[0].hour.format("%02d") + ":" + tzInfo[0].min.format("%02d"), tzInfo[1]];
    }
    
    function DisplaySunEvent(layout)
    {
        var eventTime = null;
        var location = Setting.GetLastKnownLocation();
        var time = Sys.getClockTime();
        
        if (_ecHour == time.hour && 
        	_eventTime != null &&
        	time.hour <= _eventTime[0] && time.min < _eventTime[1]) 
        {
        	eventTime = _eventTime;
        }
		else
		{
	 		if (location != null && location.size() == 2)
		    {
		        var DOY = WatchData.GetDOY(Time.now());
		        
		        // get sunrise
		        //
		    	var ne = WatchData.GetNextSunEvent(DOY, location[0], location[1], time.timeZoneOffset, time.dst, true);
		    	if (ne != null && (time.hour > ne[0] || (time.hour == ne[0] && time.min > ne[1])))
		    	{
		    		// if missed sunrise, get sunset
		    		//
		    		ne = WatchData.GetNextSunEvent(DOY, location[0], location[1], time.timeZoneOffset, time.dst, false);
		    		if (ne != null && (time.hour > ne[0] || (time.hour == ne[0] && time.min > ne[1])))
		    		{
		    			// if missed sunset, get sunrise next day
		    			//
		    			DOY = WatchData.GetDOY(Time.now().add(new Toybox.Time.Duration(86400)));
		    			ne = WatchData.GetNextSunEvent(DOY, location[0], location[1], time.timeZoneOffset, time.dst, true);
		    		}
		    	}
		    	eventTime = ne; 
		    	_ecHour = time.hour;
		    	_eventTime = eventTime;
		    }
	    }
	    
	    if (eventTime == null)
	    {
	    	return ["no gps", ""];
	    }
	    else
	    {
	    	layout["f"][1] = 101;
	    	return [eventTime[0].format("%02d") + ":" + eventTime[1].format("%02d"), eventTime[2] ? "r" : "s"];
	    }
    }
    
    // Display exchange rate
    //
    function DisplayExchangeRate(layout)
    {
    		var currencyValue = Setting.GetExchangeRate(); 
			if (currencyValue == null || currencyValue == 0)
			{
				return ["loading...", ""];
			}		
			else 
			{
				var format = (currencyValue > 1) ? "%2.2f" : "%1.3f";
				format = (currencyValue < 0.01) ? "%.4f" : format;
				format = (currencyValue < 0.001) ? "%.5f" : format;
				format = (currencyValue < 0.0001) ? "%.6f" : format;

				return [currencyValue.format(format), Setting.GetTargetCurrency().toLower()];					
			}
    }  

    // Display activity (distance)
    //
    function DisplayDistance(layout)
    {  	
        var info = ActivityMonitor.getInfo();
        var distance = (info != null && info.distance != null) ? info.distance.toFloat() : 0;
        var steps = (info != null && info.steps != null ) ? info.steps : 0;
    	var distanceValues = 
			[(distance/100000).format("%2.1f"), 
			 (distance/160934.4).format("%2.1f"), 
			 steps.format("%d")];
		var distanceTitles = ["km", "mi", "st."];
		
		return [distanceValues[Setting.GetDistSystem()], distanceTitles[Setting.GetDistSystem()]];
    }
    
    // Display the number of floors climbed for the current day.
    //
    function DisplayFloors(layout)
    {
    	var info = ActivityMonitor.getInfo();
    	if (info != null && info has :floorsClimbed && info.floorsClimbed != null)
    	{ 
    		return [info.floorsClimbed.format("%d"), "fl."]; 
    	}
    	else
    	{
    		return ["n/a", ""];
    	}
  	
    }
    
    function DisplayStepsNFloors(layout)
    {
    	var info = ActivityMonitor.getInfo();
    	if (info != null && info has :floorsClimbed && info has :steps && info.floorsClimbed != null && info.steps != null)
    	{
	    	return [info.steps.format("%d") + "/" + info.floorsClimbed.format("%d"), ""];
    	}
    	return ["n/a", ""];
    }
   
     // display current pulse
    //
    function DisplayPulse(layout)
    {       
    	var isUpdate = false;
		var chr = Activity.getActivityInfo().currentHeartRate;
		if (chr != null && _heartRate != chr)
		{
			_heartRate = chr;
			_heartRateText = (chr < 100) ? chr.toString() + "  " : chr.toString();
			isUpdate = true;
		}

		return [_heartRateText, "bpm", isUpdate];
    }

	
	function DisplayMsgCount(layout)
	{
		var ds = Sys.getDeviceSettings();
		return (ds != null && ds.notificationCount != null)
			? [ds.notificationCount.format("%d"), "msg"]
			: ["0", "msg"];
	}
	
	function DisplayAlarmCount(layout)
	{
		var ds = Sys.getDeviceSettings();
	 	return (ds != null && ds.alarmCount != null) 
			? [ds.alarmCount.format("%d"), "alm"]
			: ["0", "alm"];
	}
	
	
	function DisplayAltitude(layout)
	{
		var altitude = null;
		var info = Activity.getActivityInfo();
		if (info != null && info has :altitude && info.altitude != null)
		{
			altitude = info.altitude * (Setting.GetAltimeterSystem() == 0 ? 1 : 3.28084);
		}
		
		return [(altitude != null) ? altitude.format("%d") : "---", (Setting.GetAltimeterSystem() == 0) ? "m" : "ft"];
	}
	
	// Display the number of floors climbed for the current day.
    //
    function DisplayCalories(layout)
    {
    	return [ActivityMonitor.getInfo().calories.format("%d"), "kCal"];
    }

    // Display current city name based on known GPS location 
    //
    function DisplayLocation(layout)
    {
    	var fcity = Setting.GetCity();
    	
    	if ( fcity != null && fcity["City"] != null)
		{
			// cut <city, country> length if it's too long.
			// first cut country, if it's still not fit - cut and add dots.
			//
			var city = fcity["City"];
			
			var ppc = _dc.getTextWidthInPixels(city, _fonts[layout["f"][0]-100]) / city.length(); 			 
			var maxLen = _dc.getWidth() * .65 / ppc; // approx string width.
			
			if (city.length() > maxLen)
			{
				var dindex = city.find(",");
				city = (dindex== null || dindex == 0) 
					? city
					: city.substring(0, dindex);
				city = city.length() > maxLen ? city.substring(0, maxLen - 1) + "..." : city;
			}
			
			return [city];
		}
		else
		{
			return [""];
		}
    }
    
    // Display battery and connection status
    //
    function DisplayWatchStatus(layout)
    {
    	var stats = Sys.getSystemStats();
		var batteryLevel = (stats != null) ? (stats.battery).toNumber() : 0;
		
		// set red color if battery level too low
		// 
		layout["c"] = batteryLevel <= 20
			? [3, 3, 3, 3]
			: [2, 2, 2, 2];
	
		return (batteryLevel.format("%d") + "%").toCharArray().reverse().add("").add("");
    }
    
    ///
    /// Display notification count below main data
    ///
    function DisplayBottomMessageCount(layout)
    {
    	var ds = Sys.getDeviceSettings();
    	if (ds != null && ds has :notificationCount && ds.notificationCount != null 
    		&& ((Setting.GetShowMessage() == 1 && ds.notificationCount > 0) || Setting.GetShowMessage() == 2))
    	{
    		return ["e", ds.notificationCount.format("%d")];
    	} 
    	return ["", ""];
    }   
    
    ///
    /// Display alam count under main data
    ///
    function DisplayBottomAlarmCount(layout)
    {
    	var ds = Sys.getDeviceSettings();
    	if (ds != null && ds has :alarmCount && ds.alarmCount != null 
    		&& ((Setting.GetShowAlarm() == 1 && ds.alarmCount > 0) || Setting.GetShowAlarm() == 2))
    	{
			return ["d", ds.alarmCount.format("%d")];
    	} 
    	return ["", ""];
    }
    
}