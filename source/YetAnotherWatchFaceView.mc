using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.Activity as Activity;
using Toybox.Background as Background;

// Main WatchFaace view
// ToDo:: 
//        -- 1. Create Wrapper around ObjectStore 
//        2. Move UI logic to functions
//        -- 3. Fix Timezone Issue 
//		  -- 4. Add option to show city name
//
class YetAnotherWatchFaceView extends Ui.WatchFace 
{
	hidden var _layout;
	hidden var _conditionIcons;
	
    function initialize() 
    {
        WatchFace.initialize();
        Setting.SetLocationApiKey(Ui.loadResource(Rez.Strings.LocationApiKeyValue));
		Setting.SetAppVersion(Ui.loadResource(Rez.Strings.AppVersionValue));
    }

    // Load your resources here
    //
    function onLayout(dc) 
    {
        _layout = Rez.Layouts.MiddleDateLayout(dc);
		setLayout(_layout);
		_conditionIcons = Ui.loadResource(Rez.JsonData.conditionIcons);


		
		UpdateSetting();
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
    
  
    function UpdateSetting()
    {
		var tzData = Ui.loadResource(Rez.JsonData.tzData);
        for (var i=0; i < tzData.size(); i++ )
        {
        	if (tzData[i]["Id"] == Setting.GetEtzId())
        	{
        		Setting.SetExtraTimeZone(tzData[i]);
        		break;
        	}
        }
		tzData = null;

		SetColors();
    }
    
    // Return time and abbreviation of extra time-zone
    //
    function GetTzTime(timeNow)
    {
        var localTime = Sys.getClockTime();
        var utcTime = timeNow.add(
        	new Time.Duration( - localTime.timeZoneOffset + localTime.dst));
        
        // by dfault return UTC time
        //
       	var newTz = Setting.GetExtraTimeZone();
		if (newTz == null)
		{
			return [Gregorian.info(utcTime, Time.FORMAT_MEDIUM), "UTC"];
		}
 
 		// find right time interval
 		//
        var index = 0;
        for (var i = 0; i < newTz["Untils"].size(); i++)
        {
        	if (newTz["Untils"][i] != null && newTz["Untils"][i] > utcTime.value())
        	{
        		index = i;
        		break;
        	}
        }
        
        var extraTime = utcTime.add(new Time.Duration(newTz["Offsets"][index] * -60));        
      
        return [Gregorian.info(extraTime, Time.FORMAT_MEDIUM), newTz["Abbrs"][index]];
    }
    
    // calls every second for partial update
    //
    function onPartialUpdate(dc)
    {
    	var clockTime = Sys.getClockTime();
    	
    	var secondLabel = View.findDrawableById("Second_time_setbg");
     	dc.setClip(secondLabel.locX - secondLabel.width, secondLabel.locY, secondLabel.width + 1, secondLabel.height);
     	secondLabel.setText(clockTime.sec.format("%02d"));
		secondLabel.draw(dc);

		var chr = Activity.getActivityInfo().currentHeartRate;
		if (chr != null)
		{
			var viewPulse = View.findDrawableById("Pulse_bright_setbg");
			dc.setClip(viewPulse.locX, viewPulse.locY, viewPulse.locX + 30, viewPulse.height);
			viewPulse.setText((chr < 100) ? chr.toString() + "  " : chr.toString());
			viewPulse.draw(dc);
		}

        dc.clearClip();
    }
    
    function TrackBatteryDegradation()
    {
    	
    	var savedLevel = Setting.GetBatteryLevel();
    	var currentLevel = (Sys.getSystemStats().battery).toNumber();
    	if (savedLevel[0] != currentLevel)
    	{
    		var timeNowValue = Time.now().value();
    		var diff = timeNowValue - savedLevel[1];
    		Setting.SetBatteryLevel([currentLevel, timeNowValue]);
    	}
    }

    // Update the view
    //
    function onUpdate(dc) 
    {
    	var activityLocation = Activity.getActivityInfo().currentLocation;
    	if (activityLocation != null)
    	{
    		Setting.SetLastKnownLocation(activityLocation.toDegrees());
    	}
    	
		var timeNow = Time.now();
        var gregorianTimeNow = Gregorian.info(timeNow, Time.FORMAT_MEDIUM);
    	
        // Update Time
        //
        View.findDrawableById("Hour_time")
        	.setText(gregorianTimeNow.hour.format("%02d"));
        
        var viewMinute = View.findDrawableById("Minute_time")
        	.setText(gregorianTimeNow.min.format("%02d"));
        
        View.findDrawableById("Second_time_setbg")
        	.setText(gregorianTimeNow.sec.format("%02d"));
         
        // Update date
        //
        View.findDrawableById("WeekDay_bright")
        	.setText(gregorianTimeNow.day_of_week.toLower());
        
        View.findDrawableById("Month_dim")
        	.setText(gregorianTimeNow.month.toLower());
        
        View.findDrawableById("Day_bright")
        	.setText(gregorianTimeNow.day.format("%02d"));
        
        // Update time in diff TZ
        //
		var tzInfo = GetTzTime(timeNow);

        View.findDrawableById("TzTime_bright")
        	.setText(tzInfo[0].hour.format("%02d") + ":" + tzInfo[0].min.format("%02d"));

        View.findDrawableById("TzTimeTitle_dim")
        	.setText(tzInfo[1]);
        
        // get ActivityMonitor info
        //
		var info = ActivityMonitor.getInfo();
		var distance = info.distance.toFloat()/100000;
		
        View.findDrawableById("Dist_bright")
        	.setText(distance.format("%2.1f"));
        
        // Weather data
        //
        var weatherInfo = null;
        if (Setting.GetWeatherInfo() != null)
        {
        	weatherInfo = WeatherInfo.FromDictionary(Setting.GetWeatherInfo());
        }
        if (weatherInfo == null || weatherInfo.WeatherStatus != 1) // no weather
        {
			View.findDrawableById("Temperature_bright")
				.setText((Setting.GetLastKnownLocation() == null) ? "no GPS" : "GPS ok");
			View.findDrawableById("TemperatureTitle_dim").setText("");
			View.findDrawableById("Perception_bright").setText("");
			View.findDrawableById("PerceptionTitle_dim").setText("");
			View.findDrawableById("Wind_bright").setText("");
			View.findDrawableById("WindTitle_dim").setText("");
        }
        else
        {
			var temperature = Lang.format("$1$", [weatherInfo.Temperature.format("%2.1f")]);
			var perception = Lang.format("$1$", [weatherInfo.PerceptionProbability.format("%2d")]);
	        
			var temperatureLabel = View.findDrawableById("Temperature_bright");
			temperatureLabel.setText(temperature);
			var temperatureTitleLabel = View.findDrawableById("TemperatureTitle_dim");
			temperatureTitleLabel.locX = temperatureLabel.locX + dc.getTextWidthInPixels(temperature, Gfx.FONT_TINY);
			temperatureTitleLabel.setText("o");
			
			View.findDrawableById("Perception_bright").setText(perception);
			View.findDrawableById("PerceptionTitle_dim").setText("%");
			
			var windLabel = View.findDrawableById("Wind_bright");
			var wind = weatherInfo.WindSpeed.format("%2.1f");
			windLabel.setText(wind);		
			var windTitleLabel = View.findDrawableById("WindTitle_dim");
			windTitleLabel.locX = windLabel.locX + dc.getTextWidthInPixels(wind, Gfx.FONT_TINY) + 1;
			windTitleLabel.setText("kn");
	
			var icon = _conditionIcons[weatherInfo.Condition];
			if (icon != null)
			{
				View.findDrawableById("Condition_time").setText(icon);
			}
		}
		
		if (weatherInfo != null && weatherInfo.City != null 
			&& weatherInfo.CityStatus == 1 && Setting.GetIsShowCity())
		{
			View.findDrawableById("City_dim").setText(weatherInfo.City);
		}
		else
		{
			View.findDrawableById("City_dim").setText("");
		}

		// watch status
		//
		var connectionState = Sys.getDeviceSettings().phoneConnected;
		var viewBt = View.findDrawableById("Bluetooth_dim")
			.setText(connectionState ? "a" : "b");
		
		var batteryLevel = (Sys.getSystemStats().battery).toNumber();
		View.findDrawableById("Battery1_dim").setText((batteryLevel % 10).format("%1d"));
		batteryLevel = batteryLevel / 10;
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

		View.findDrawableById("debug_version").setText(Rez.Strings.AppVersionValue);
		
        // Call the parent onUpdate function to redraw the layout
        //
        View.onUpdate(dc);
    }
}
