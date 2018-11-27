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
//        -- 6. Refactor backround process (error handling)
//        -- 7. Option to Show weather
//        8. Refactor resources, name conventions, etc..
//
class YetAnotherWatchFaceView extends Ui.WatchFace 
{
	hidden var _layout;
	hidden var _conditionIcons;
	hidden var _heartRate = 0;
	hidden var _methods = [:DisplayExtraTz, :DisplayCurrency, :DisplayDistance];
	
    function initialize() 
    {
        WatchFace.initialize();
        Setting.SetLocationApiKey(Ui.loadResource(Rez.Strings.LocationApiKeyValue));
		Setting.SetAppVersion(Ui.loadResource(Rez.Strings.AppVersionValue));
		Setting.SetIsTest(Ui.loadResource(Rez.Strings.IsTest).toNumber() == 1 ? true : false);

		//Setting.SetLastKnownLocation([13.764073, 100.577436]);
    }

    // Load your resources here
    //
    function onLayout(dc) 
    {
        _layout = Rez.Layouts.MiddleDateLayout(dc);
		setLayout(_layout);
		_conditionIcons = Ui.loadResource(Rez.JsonData.conditionIcons);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    //
    function onShow() 
    {
		SetColors();
	}
	
	// Set colors according to property name and app setting
	// 
    function SetColors()
    {
    	for(var i = 0; i < _layout.size(); i++)
    	{
    		if(_layout[i].identifier.find("_time") != null)
    		{
    			_layout[i].setColor(Setting.GetTimeColor());
    		}
    		if(_layout[i].identifier.find("_setbg") != null)
    		{
    			_layout[i].setBackgroundColor(Setting.GetBackgroundColor());
    		}
    		if(_layout[i].identifier.find("_bright") != null)
    		{
    			_layout[i].setColor(Setting.GetBrightColor());
    		}
    		if(_layout[i].identifier.find("_dim") != null)
    		{
    			_layout[i].setColor(Setting.GetDimColor());
    		}
    	}
    	
    	View.findDrawableById("divider")
    		.setLineColor(Setting.GetTimeColor());
    }
    
     
    // calls every second for partial update
    //
    function onPartialUpdate(dc)
    {
    	if (Setting.GetIsShowSeconds())
    	{
	    	var clockTime = Sys.getClockTime();
	    	
	    	var secondLabel = View.findDrawableById("Second_time_setbg");
	     	dc.setClip(secondLabel.locX - secondLabel.width, secondLabel.locY, secondLabel.width + 1, secondLabel.height);
	     	secondLabel.setText(clockTime.sec.format("%02d"));
			secondLabel.draw(dc);
		}
		
		if (!Setting.GetIsShowCurrency())
		{
			DisplayPulseFull(dc, false);
		}
    }
    
    // Update the view
    //
    function onUpdate(dc) 
    {
    	var watchInfo = WatchData.GetWatchInfo();
    	
    	var activityLocation = watchInfo.CurrentLocation;
    	if (activityLocation != null)
    	{
    		Setting.SetLastKnownLocation(activityLocation.toDegrees());
    	}

		DisplayTimeNDate(dc, watchInfo);
		
        // Weather data
        //
        var weatherInfo = null;
        if (Setting.GetWeatherInfo() != null)
        {
        	weatherInfo = WeatherInfo.FromDictionary(Setting.GetWeatherInfo());
        }
		DisplayWeather(dc, weatherInfo);		
          
        // Update time in diff TZ
        //
        new Lang.Method(self, _methods[0]).invoke(dc);
		//DisplayExtraTz();
        
        // get ActivityMonitor info
        //
        new Lang.Method(self, _methods[2]).invoke(dc);
		//DisplayActivity(watchInfo);
       
        // Show Currency
        //
       	if (Setting.GetIsShowCurrency())
		{
			new Lang.Method(self, _methods[1]).invoke(dc);
		}
		else
		{
			DisplayPulse(dc);
		}		
		
		// location
		//
		DisplayLocation(weatherInfo);

		// watch status
		//
		DisplayWatchStatus(watchInfo);

		if (Setting.GetIsTest())
		{
			View.findDrawableById("debug_version").setText(Rez.Strings.AppVersionValue);
		}
		
        // Call the parent onUpdate function to redraw the layout
        //
        weatherInfo = null;
        watchInfo = null;
        dc.clearClip();
        View.onUpdate(dc);
    }
    
    // Display current time and date
    //
    function DisplayTimeNDate(dc, watchInfo)
    {
    	var gregorianTimeNow = Gregorian.info(watchInfo.Time, Time.FORMAT_MEDIUM);
    	
        // Update Time
        //
        View.findDrawableById("Hour_time")
        	.setText(watchInfo.Is24Hour 
        		? gregorianTimeNow.hour.format("%02d") 
        		: (gregorianTimeNow.hour % 12 == 0 ? 12 : gregorianTimeNow.hour % 12).format("%02d"));
        	
        View.findDrawableById("DaySign_time_setbg")
        	.setText(watchInfo.Is24Hour ? "" : gregorianTimeNow.hour > 11 ? "pm" : "am");
        
        View.findDrawableById("Minute_time")
        	.setText(gregorianTimeNow.min.format("%02d"));
        
       	View.findDrawableById("Second_time_setbg")
        		.setText(Setting.GetIsShowSeconds() ? gregorianTimeNow.sec.format("%02d") : "");
        
        // Update date
        //
        var dayText = gregorianTimeNow.day.format("%02d");
        var dayLabel = View.findDrawableById("Day_bright");
        dayLabel.setText(dayText);
        	
        var monthText = gregorianTimeNow.month.toLower();
        var monthLabel = findDrawableById("Month_dim");
        monthLabel.locX = dayLabel.locX - dc.getTextWidthInPixels(dayText, Gfx.FONT_XTINY) - 5;
        monthLabel.setText(monthText);	
        
        var dowLabel = View.findDrawableById("WeekDay_bright");
        dowLabel.locX = monthLabel.locX - dc.getTextWidthInPixels(monthText, Gfx.FONT_TINY) - 7;
        dowLabel.setText(gregorianTimeNow.day_of_week.toLower());
    }
    
    function DisplayExtraTz(dc)
    {
    	var tzInfo = WatchData.GetTzTime(Time.now(), Setting.GetExtraTimeZone());
    	
        View.findDrawableById("TzTime_bright")
        	.setText(tzInfo[0].hour.format("%02d") + ":" + tzInfo[0].min.format("%02d"));

        View.findDrawableById("TzTimeTitle_dim")
        	.setText(tzInfo[1]);
    }
    
    // call from main update as a callback function
    //
    function DisplayPulse(dc)
    {
    	DisplayPulseFull(dc, true);
    }
    
    // display current pulse
    //
    function DisplayPulseFull(dc, isFullUpdate)
    {
    	if (isFullUpdate)
		{	
			View.findDrawableById("Pulse_bright_setbg").setText("--    ");
			View.findDrawableById("PulseTitle_dim").setText("bpm");
		}
    
		var chr = Activity.getActivityInfo().currentHeartRate;
		if (chr != null && _heartRate != chr)
		{
			_heartRate = chr;
			var viewPulse = View.findDrawableById("Pulse_bright_setbg");
			viewPulse.setText((chr < 100) ? chr.toString() + "  " : chr.toString());
			if (!isFullUpdate)
			{
				dc.setClip(viewPulse.locX, viewPulse.locY, viewPulse.locX + 30, viewPulse.height);
				viewPulse.draw(dc);
			}
		}
    }
    
    // Display activity (distance)
    //
    function DisplayDistance(dc)
    {
        var info = ActivityMonitor.getInfo();
    	var distanceValues = 
			[(info.distance.toFloat()/100000).format("%2.1f"), 
			 (info.distance.toFloat()/160934.4).format("%2.1f"), 
			 info.steps.format("%02d")];
		var distanceTitles = ["km", "mi", ""];
		
        View.findDrawableById("Dist_bright")
        	.setText(distanceValues[Setting.GetDistSystem()]);
        
        View.findDrawableById("DistTitle_dim")
        	.setText(distanceTitles[Setting.GetDistSystem()]);
        	
        distanceValues = null;
        distanceTitles = null;
    }
    
    
    // Show weather
    //
    function DisplayWeather(dc, weatherInfo)
    {
    	if (weatherInfo == null || weatherInfo.WeatherStatus != 1 || !Setting.GetIsShowWeather()) // no weather
        {
			View.findDrawableById("Temperature_bright")
				.setText(
					!Setting.GetIsShowWeather() ? "" :
						(Setting.GetLastKnownLocation() == null) ? "no GPS" : "GPS ok");
			View.findDrawableById("TemperatureTitle_dim").setText("");
			View.findDrawableById("Perception_bright").setText("");
			View.findDrawableById("PerceptionTitle_dim").setText("");
			View.findDrawableById("Wind_bright").setText("");
			View.findDrawableById("WindTitle_dim").setText("");
			View.findDrawableById("Condition_time").setText("");
        }
        else
        {
			var temperature = (Setting.GetTempSystem() == 1 ? weatherInfo.Temperature : weatherInfo.Temperature * 1.8 + 32)
				.format(weatherInfo.PerceptionProbability > 99 ? "%2d" : "%2.1f");
			var perception = weatherInfo.PerceptionProbability.format("%2d");
	        
			var temperatureLabel = View.findDrawableById("Temperature_bright");
			temperatureLabel.setText(temperature);
			var temperatureTitleLabel = View.findDrawableById("TemperatureTitle_dim");
			temperatureTitleLabel.locX = temperatureLabel.locX + 1 + dc.getTextWidthInPixels(temperature, Gfx.FONT_TINY);
			temperatureTitleLabel.setText(Setting.GetTempSystem() == 1 ? "c" : "f");
			
			View.findDrawableById("Perception_bright").setText(perception);
			View.findDrawableById("PerceptionTitle_dim").setText("%");
			
			var windLabel = View.findDrawableById("Wind_bright");
			var wind = (weatherInfo.WindSpeed * (Setting.GetWindSystem() == 1 ? 1.94384 : 1)).format("%2.1f");
			windLabel.setText(wind);		
			var windTitleLabel = View.findDrawableById("WindTitle_dim");
			windTitleLabel.locX = windLabel.locX + dc.getTextWidthInPixels(wind, Gfx.FONT_TINY) + 1;
			windTitleLabel.setText(Setting.GetWindSystem() == 1 ? "kn" : "m/s");
	
			var icon = _conditionIcons[weatherInfo.Condition];
			if (icon != null)
			{
				View.findDrawableById("Condition_time").setText(icon);
			}
		}
    }
    
    // Display exchange rate
    //
    function DisplayCurrency(dc)
    {
    		var currencyValue = Setting.GetExchangeRate(); 
			if (currencyValue == null || currencyValue == 0)
			{
				View.findDrawableById("Pulse_bright_setbg")
					.setText("loading...");
				View.findDrawableById("PulseTitle_dim").setText("");					
			}		
			else 
			{
				var format = (currencyValue > 1) ? "%2.2f" : "%1.3f";
				format = (currencyValue < 0.01) ? "%.4f" : format;
				format = (currencyValue < 0.001) ? "%.5f" : format;
				format = (currencyValue < 0.0001) ? "%.6f" : format;
					
				var rateString = currencyValue.format(format);	
				var exchangeLabel = View.findDrawableById("Pulse_bright_setbg");
				exchangeLabel.setText(rateString);
				
				var currencyLabel = View.findDrawableById("PulseTitle_dim");
				if (rateString.length() > 5)
				{
					currencyLabel.locX = exchangeLabel.locX + dc.getTextWidthInPixels(rateString, Gfx.FONT_TINY) + 3;
				}
				else
				{
					currencyLabel.locX = View.findDrawableById("DistTitle_dim").locX;
				}
				currencyLabel.setText(Setting.GetTargetCurrency().toLower());
			}
    }
    
    // Display current city name based on known GPS location 
    //
    function DisplayLocation(weatherInfo)
    {
    	if (weatherInfo != null && weatherInfo.City != null 
			&& weatherInfo.CityStatus == 1 && Setting.GetIsShowCity())
		{
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
			View.findDrawableById("City_dim").setText(city);
			city = null;
		}
		else
		{
			View.findDrawableById("City_dim").setText("");
		}
    }
    
    // Display battery and connection status
    //
    function DisplayWatchStatus(watchInfo)
    {
    	var viewBt = View.findDrawableById("Bluetooth_dim")
			.setText(watchInfo.ConnectionState ? "a" : "b");
		
		View.findDrawableById("Battery1_dim").setText((watchInfo.BatteryLevel % 10).format("%1d"));
		var batteryLevel = watchInfo.BatteryLevel / 10;
		if (batteryLevel == 10 )
		{
			View.findDrawableById("Battery3_dim").setText("1");
			View.findDrawableById("Battery2_dim").setText("0");
		}
		else
		{
			View.findDrawableById("Battery3_dim").setText("");
			if (batteryLevel > 0)
			{
				View.findDrawableById("Battery2_dim").setText((batteryLevel % 10).format("%1d"));
			}
			else
			{
				View.findDrawableById("Battery2_dim").setText("");
			}
		}
    }
}
