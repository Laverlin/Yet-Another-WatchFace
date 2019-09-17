using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.Activity as Activity;

// Main WatchFaace view
// ToDo:: 
//        -- 1. Create Wrapper around ObjectStore 
//        -- 2. Move UI logic to functions
//        -- 3. Fix Timezone Issue 
//		  -- 4. Add option to show city name
//		  -- 5. Adjust exchange rate output
//        6. Refactor backround process (error handling)
//        -- 7. Option to Show weather
//        8. Refactor resources, name conventions, etc..
//
class YetAnotherWatchFaceView extends Ui.WatchFace 
{
	hidden var _layout;
	hidden var _conditionIcons = Ui.loadResource(Rez.JsonData.conditionIcons);
	hidden var _heartRate = 0;
	hidden var _heartRateText = "-- ";
	hidden var _methods = [
		:DisplayExtraTz, :DisplayExchangeRate, :DisplayDistance, :DisplayPulse, 
		:DisplayFloors, :DisplayMsgCount, :DisplayAlarmCount, :DisplayAltitude, 
		:DisplayCalories, :DisplayStepsNFloors, :DisplaySunEvent];
	hidden var _ecHour = null;
	hidden var _eventTime = null;
	
	hidden var _layouts = {};
	hidden var _fonts = [
		Ui.loadResource(Rez.Fonts.msss16_font), Ui.loadResource(Rez.Fonts.icon_font), Ui.loadResource(Rez.Fonts.vertical_font)];
	hidden var _colors = [Setting.GetTimeColor(), Setting.GetBrightColor(), Setting.GetDimColor(), Gfx.COLOR_RED];
	hidden var _funcs = [
		:DisplayLocation, :DisplayBottomAlarmCount, :DisplayBottomMessageCount, 
		:DisplayDate, :DisplayTime, :DisplayPmAm, :DisplaySeconds,
		:DisplayTemp, :DisplayWind, :DisplayConnection, 
		:LoadField3, :LoadField4, :LoadField5, 
		:DisplayWatchStatus];
	
	hidden var _gTimeNow;
	hidden var _secDim;
	hidden var _is90 = false;
	
	
    function initialize() 
    {
        WatchFace.initialize();
        Setting.SetLocationApiKey(Ui.loadResource(Rez.Strings.LocationApiKeyValue));
		Setting.SetAppVersion(Ui.loadResource(Rez.Strings.AppVersionValue));
		Setting.SetExchangeApiKey(Ui.loadResource(Rez.Strings.ExchangeApiKeyValue));
		Setting.SetIsTest(Ui.loadResource(Rez.Strings.IsTest).toNumber() == 1 ? true : false);

		//Setting.SetLastKnownLocation([13.764073, 100.577436]);
    }

    // Load your resources here
    //
    function onLayout(dc) 
    {
    	_secDim = [dc.getTextWidthInPixels("00", Gfx.FONT_TINY), dc.getFontHeight(Gfx.FONT_TINY)];
    	_is90 = (dc.getFontHeight(Gfx.FONT_NUMBER_HOT) == 90 || dc.getFontHeight(Gfx.FONT_NUMBER_HOT) == 82) ? true : false;

		InvalidateLayout();
    }
    
    // calls every second for partial update
    //
    function onPartialUpdate(dc)
    {
    	if (Setting.GetIsShowSeconds())
    	{
	    	dc.setClip(_layouts["sec"]["x"][0] - _secDim[0], _layouts["sec"]["y"][0], _layouts["sec"]["x"][0] + 1, _secDim[1]);
	    	dc.setColor(Setting.GetTimeColor(), Setting.GetBackgroundColor());
	    	dc.drawText(
	    		_layouts["sec"]["x"][0], 
	    		_layouts["sec"]["y"][0], 
	    		Gfx.FONT_TINY, 
	    		Sys.getClockTime().sec.format("%02d"), 
	    		Gfx.TEXT_JUSTIFY_RIGHT);
		}
		
		if (Setting.GetPulseField() != 0)
		{
			var layout = _layouts["field" + Setting.GetPulseField()];
			var pulseData = DisplayPulse(layout);
			
			if (pulseData[2])
			{
				dc.setClip(layout["x"][0], layout["y"][0], layout["x"][0] + _secDim[0], _secDim[1]);
				dc.setColor(Setting.GetBrightColor(), Setting.GetBackgroundColor());
				dc.drawText(layout["x"][0], layout["y"][0], Gfx.FONT_TINY, pulseData[0], Gfx.TEXT_JUSTIFY_LEFT);
			}
		}
    }
    
    // Update the view
    //
    function onUpdate(dc) 
    {
   		_gTimeNow = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
    	var activityLocation = Activity.getActivityInfo().currentLocation;
    	if (activityLocation != null)
    	{
    		Setting.SetLastKnownLocation(activityLocation.toDegrees());
    		//Setting.SetLastKnownLocation([7.823586, 98.236482]);
    	}

		dc.clearClip();
		dc.setColor(Gfx.COLOR_TRANSPARENT, Setting.GetBackgroundColor());
    	dc.clear();
    	
		for (var i = 0; i < _layouts.size(); i++)
		{
			var funcs = (new Lang.Method(self, _funcs[_layouts.values()[i]["fun"]]).invoke());
				
			var x = null;
			var f = null;	
			var text = null;
			for(var j = 0; j < _layouts.values()[i]["x"].size(); j++)
			{
				dc.setColor(_colors[_layouts.values()[i]["c"][j]], 
					_layouts.values()[i].hasKey("tb") ? Gfx.COLOR_TRANSPARENT : Setting.GetBackgroundColor());

	        	var a = _layouts.values()[i]["a"][j];
	        	
	        	// if lcor is present AND lenght of prev text is greater than default X. 
	        	// then default x should be increased on lcor
	        	//
	        	if (_layouts.values()[i].hasKey("lcor") && 
	        		_layouts.values()[i]["lcor"] != null &&
	        		text != null &&
	        		x + dc.getTextWidthInPixels(text, f) > _layouts.values()[i]["x"][j])
	        	{
	        		x = x + dc.getTextWidthInPixels(text, f) + _layouts.values()[i]["lcor"];
	        	}
	        	else
	        	{
		        	// if cor is present default X should be adjasted on cor
		        	//
		        	if (_layouts.values()[i].hasKey("cor") && 
		        		_layouts.values()[i]["cor"][j] != null &&
		        		text != null) 
		        	{
		        		x = x + (a == 0 ? -1 : 1) * dc.getTextWidthInPixels(text, f) + _layouts.values()[i]["cor"][j];
		        	}
		        	else
		        	{
		        		x = _layouts.values()[i]["x"][j];
		        	}
	        	}

				f = _layouts.values()[i]["f"][j] < 100 
	        			? _layouts.values()[i]["f"][j] 
	        			: _fonts[_layouts.values()[i]["f"][j] - 100];

				text = (_layouts.values()[i]["t"][j] == null)
					? funcs[j] 
	        		: _layouts.values()[i]["t"][j];
	        			
				dc.drawText(x, _layouts.values()[i]["y"][j], f, text, a);
			}
		}
		
		dc.setColor(Setting.GetTimeColor(), Gfx.COLOR_TRANSPARENT);
        dc.drawLine(120, 54, 120, 186);
        
        if (Setting.GetIsTest())
		{
			dc.setColor(Setting.GetDimColor(), Gfx.COLOR_TRANSPARENT);
			dc.drawText(120, 220, _fonts[0], Ui.loadResource(Rez.Strings.AppVersionValue), Gfx.TEXT_JUSTIFY_CENTER);
		}
    }
    
    function InvalidateLayout()
    {
    	_layouts = {};
    	_layouts.put("city", Ui.loadResource(Setting.GetCityAlign() == 0 ? Rez.JsonData.l_city_left : Rez.JsonData.l_city_center));   	
    	
		_layouts.put("hour", Ui.loadResource(_is90 ? Rez.JsonData.l_time_f90 : Rez.JsonData.l_time));
    	_layouts.put("date", Ui.loadResource(_is90 ? Rez.JsonData.l_date_f90 : Rez.JsonData.l_date));
		_layouts.put("btooth", Ui.loadResource(Rez.JsonData.l_bt));    	
    	
    	if (Setting.GetIsShowSeconds())
    	{
    		_layouts.put("sec", Ui.loadResource(Rez.JsonData.l_sec));
    	}
    	
    	if (!Sys.getDeviceSettings().is24Hour)
    	{
    		_layouts.put("pmam", Ui.loadResource(_is90 ? Rez.JsonData.l_pmam_f90 : Rez.JsonData.l_pmam));
    	}
    	
    	if (Setting.GetIsShowWeather())
    	{
    		_layouts.put("temp", Ui.loadResource(Rez.JsonData.l_temp));
    		_layouts.put("wind", Ui.loadResource(Rez.JsonData.l_wind));
    	}
    	
    	if (Setting.GetShowAlarm() > 0)
    	{
    		_layouts.put("alarm", Ui.loadResource(Setting.GetAlarmAlign() == 0 ? Rez.JsonData.l_alarm_right : Rez.JsonData.l_alarm_center));
    	}
    	
    	if (Setting.GetShowMessage() > 0)
    	{
    		_layouts.put("msg", Ui.loadResource(Setting.GetAlarmAlign() == 0 ? Rez.JsonData.l_msg_right : Rez.JsonData.l_msg_center));
    	}    	
    	
    	_layouts.put("field3", Ui.loadResource(Rez.JsonData.l_field3));
    	_layouts.put("field4", Ui.loadResource(Rez.JsonData.l_field4));
    	_layouts.put("field5", Ui.loadResource(Rez.JsonData.l_field5));
    	_layouts.put("battery", Ui.loadResource(Rez.JsonData.l_battery));
     }
    
    function LoadField3()
    {
       	return new Lang.Method(self, _methods[Setting.GetField(3)]).invoke(_layouts["field3"]);
    }
    
   	function LoadField4()
    {
       	return new Lang.Method(self, _methods[Setting.GetField(4)]).invoke(_layouts["field4"]);
    }
    
    function LoadField5()
    {
       	return new Lang.Method(self, _methods[Setting.GetField(5)]).invoke(_layouts["field5"]);
    }
    
    ///
    /// returns [day, month, DOW]
    ///
    function DisplayDate()
    {
    	return [_gTimeNow.day.format("%02d"), _gTimeNow.month.toLower(), _gTimeNow.day_of_week.toLower()] ;
    }

    ///
    /// returns [Hour, Min]
    ///
    function DisplayTime()
    {
    	return [Sys.getDeviceSettings().is24Hour 
        			? _gTimeNow.hour.format("%02d") 
        			: (_gTimeNow.hour % 12 == 0 ? 12 : _gTimeNow.hour % 12).format("%02d"),
        		_gTimeNow.min.format("%02d")];
    }  
       
    ///
    /// returns [pm|am]
    ///   
    function DisplayPmAm()
    {
    	return [_gTimeNow.hour > 11 ? "pm" : "am"];
    }
    
    ///
    /// returns [seconds]
    ///
    function DisplaySeconds()
    {
    	return [Sys.getClockTime().sec.format("%02d")];
    }
 
    ///
    /// returns [connection status]
    ///   
    function DisplayConnection()
    {
    	return [Sys.getDeviceSettings().phoneConnected ? "a" : "b"];
    }
    
    ///
    /// returns temperature and perception probability
    ///
    function DisplayTemp()
    {
    	var weatherInfo = (Setting.GetWeatherInfo() != null) 
    		? WeatherInfo.FromDictionary(Setting.GetWeatherInfo())
    		: null;

    	if (weatherInfo == null || weatherInfo.WeatherStatus != 1 ) // no weather
        {
			var temp =  Setting.GetLastKnownLocation() == null 
						? "no GPS" 
						: (Setting.GetWeatherApiKey() == null || Setting.GetWeatherApiKey().length() == 0)
							? "no key" 
							: "loading...";
			return [temp, "", "", ""];
        }
        else
        {
        	var temp = (Setting.GetTempSystem() == 1 ? weatherInfo.Temperature : weatherInfo.Temperature * 1.8 + 32)
				.format(weatherInfo.PerceptionProbability > 99 ? "%d" : "%2.1f");
			var perception = weatherInfo.PerceptionProbability.format("%2d");
			
			return [temp, Setting.GetTempSystem() == 1 ? "c" : "f", weatherInfo.PerceptionProbability.format("%2d"), "%"];
        }
    }
    
    function DisplayWind()
    {
    	var weatherInfo = (Setting.GetWeatherInfo() != null) 
    		? WeatherInfo.FromDictionary(Setting.GetWeatherInfo())
    		: null;

    	if (weatherInfo == null || weatherInfo.WeatherStatus != 1 ) // no weather
        {
        	return ["", "", ""];
        }
        else
        {
        	var windMultiplier = [3.6, 1.94384, 1];
        	var windSystemLabel = ["k/h", "kn", "m/s"];
        	
        	return [(weatherInfo.WindSpeed * windMultiplier[Setting.GetWindSystem()]).format("%2.1f"),
        		windSystemLabel[Setting.GetWindSystem()],
        		(_conditionIcons[weatherInfo.Condition] == null) 
        			? ""
        			: _conditionIcons[weatherInfo.Condition]];
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
    	var distanceValues = 
			[(info.distance.toFloat()/100000).format("%2.1f"), 
			 (info.distance.toFloat()/160934.4).format("%2.1f"), 
			 info.steps.format("%d")];
		var distanceTitles = ["km", "mi", "st."];
		
		return [distanceValues[Setting.GetDistSystem()], distanceTitles[Setting.GetDistSystem()]];
    }
    
    // Display the number of floors climbed for the current day.
    //
    function DisplayFloors(layout)
    {
    	var floors = ActivityMonitor.getInfo().floorsClimbed;
    	return [floors.format("%d"), "fl."];
    }
    
    function DisplayStepsNFloors(layout)
    {
    	var floors = ActivityMonitor.getInfo().floorsClimbed;
    	var steps = ActivityMonitor.getInfo().steps;
    	return [steps.format("%d") + "/" + floors.format("%d"), ""];
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
		return [Sys.getDeviceSettings().notificationCount.format("%d"), "msg"]; 
	}
	
	function DisplayAlarmCount(layout)
	{
		return [Sys.getDeviceSettings().alarmCount.format("%d"), "alm"];
	}
	
	
	function DisplayAltitude(layout)
	{
		var altitude = Activity.getActivityInfo().altitude;
		if (altitude != null)
		{
			altitude = altitude * (Setting.GetAltimeterSystem() == 0 ? 1 : 3.28084);
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
    function DisplayLocation()
    {
    
    	var weatherInfo = null;
        if (Setting.GetWeatherInfo() != null)
        {
        	weatherInfo = WeatherInfo.FromDictionary(Setting.GetWeatherInfo());
        }
        
    	if (weatherInfo != null && weatherInfo.City != null 
			&& weatherInfo.CityStatus == 1)
		{
			//var aligns = [Rez.JsonData.l_city_left, Rez.JsonData.l_city_center];
		
			// short <city, country> length if it's too long.
			// first cut country, if it's still not fit - cut and add dots.
			//
			var city = weatherInfo.City;
			if (city.length() > 23)
			{
				var dindex = city.find(",");
				city = (dindex == 0) 
					? city
					: city.substring(0, dindex);
				city = city.length() > 23 ? city.substring(0, 22) + "..." : city;
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
    function DisplayWatchStatus()
    {
		var batteryLevel = (Sys.getSystemStats().battery).toNumber();
		
		// set red color if battery level too low
		// 
		_layouts["battery"]["c"] = batteryLevel <= 20
			? [3, 3, 3, 3]
			: [2, 2, 2, 2];
	
		return (batteryLevel.format("%d") + "%").toCharArray().reverse().add("").add("");
    }
    
    ///
    /// Display alam count under main data
    ///
    function DisplayBottomAlarmCount()
    {
    	var alarmCount = Sys.getDeviceSettings().alarmCount;
    	if (Setting.GetShowAlarm() == 1 and alarmCount == 0)
    	{
			return ["", ""];
    	} 
    	
		return ["d", alarmCount.format("%d")];
    }
    
    ///
    /// Display notification count under main data
    ///
    function DisplayBottomMessageCount()
    {
    	var msgCount = Sys.getDeviceSettings().notificationCount;
    	if  (Setting.GetShowMessage() == 1 and msgCount == 0)
    	{
			return ["", ""];
    	} 
		return ["e", msgCount.format("%d")];     
    }   
}
