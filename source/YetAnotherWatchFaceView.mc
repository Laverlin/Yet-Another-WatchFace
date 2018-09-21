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

class YetAnotherWatchFaceView extends Ui.WatchFace 
{
	hidden var _layout;
	
	hidden var _backgroundColor;
	hidden var _timeColor;
	hidden var _brightColor;
	hidden var _dimColor;
	hidden var _extraTimeZone;

	hidden var _weatherApiKey;
	hidden var _weatherApiUrl;
	
	hidden var _tzTitleDictionary;	
	hidden var _conditionIcons;
	
	hidden var _pulseXClipPrev = 0;
	hidden var _pulseXClip = 0;
	
	hidden var _chr;
	
    function initialize() 
    {
        WatchFace.initialize();
    }

    // Load your resources here
    //
    function onLayout(dc) 
    {
        _layout = Rez.Layouts.MiddleDateLayout(dc);
		setLayout(_layout);
		_tzTitleDictionary = Ui.loadResource(Rez.JsonData.tzTitleDictionary);
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
	
    function SetColors()
    {
    	for(var i = 0; i < _layout.size(); i++)
    	{
    		if(_layout[i].identifier.find("_time") != null)
    		{
    			_layout[i].setColor(_timeColor);
    		}
    		if(_layout[i].identifier.find("_setbg") != null)
    		{
    			_layout[i].setBackgroundColor(_backgroundColor);
    		}
    		if(_layout[i].identifier.find("_bright") != null)
    		{
    			_layout[i].setColor(_brightColor);
    		}
    		if(_layout[i].identifier.find("_dim") != null)
    		{
    			_layout[i].setColor(_dimColor);
    		}
    	}
    	
    	View.findDrawableById("divider")
    		.setLineColor(_timeColor);
    }
    
  
    function UpdateSetting()
    {
	 	_timeColor = App.getApp().getProperty("TimeColor");
	 	_backgroundColor = App.getApp().getProperty("BackgroundColor");
		_brightColor = App.getApp().getProperty("BrightColor");
		_dimColor = App.getApp().getProperty("DimColor");
		
		_extraTimeZone = App.getApp().getProperty("ExtraTimeZone");
		
		_weatherApiUrl = "https://api.darksky.net/forecast";
		_weatherApiKey = App.getApp().getProperty("WeatherApiKey");

		SetColors();
    }
    
    function GetTzTime(timeNow)
    {
    	// Update Time in extra timezone
        //
        var localTime = Sys.getClockTime();
        var localTz = new Time.Duration( - localTime.timeZoneOffset + localTime.dst);
        var extraTz = new Time.Duration(_extraTimeZone);
        var extraTime = timeNow.add(localTz).add(extraTz);
        return Gregorian.info(extraTime, Time.FORMAT_MEDIUM);
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
			_pulseXClip = viewPulse.locX + viewPulse.width + 1; // needs to clear clip area if pulse shrinks from 3 digits to 2
			dc.setClip(viewPulse.locX, viewPulse.locY, (_pulseXClip > _pulseXClipPrev) ? _pulseXClip : _pulseXClipPrev, viewPulse.height);
			_pulseXClipPrev = _pulseXClip;
			viewPulse.setText(chr.toString());
			viewPulse.draw(dc);
		}

        dc.clearClip();
    }

    // Update the view
    //
    function onUpdate(dc) 
    {
    	var activityLocation = Activity.getActivityInfo().currentLocation;
    	if (activityLocation != null)
    	{
    		App.getApp().setProperty("lastKnownLocation", activityLocation.toDegrees());
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
		var gregorianTzTime = GetTzTime(timeNow);
		var tzTitle = _tzTitleDictionary[_extraTimeZone.toString()]; 
        View.findDrawableById("TzTime_bright")
        	.setText(gregorianTzTime.hour.format("%02d") + ":" + gregorianTzTime.min.format("%02d"));

        View.findDrawableById("TzTimeTitle_dim")
        	.setText(tzTitle);
        
        // get ActivityMonitor info
        //
		var info = ActivityMonitor.getInfo();
		var distance = info.distance.toFloat()/100000;
		
        View.findDrawableById("Dist_bright")
        	.setText(distance.format("%2.1f"));
        
        // Weather data
        //
        if (App.getApp().getProperty("WeatherInfo") == null) // no weather
        {
			View.findDrawableById("Temperature_bright")
				.setText((App.getApp().getProperty("lastKnownLocation") == null)?"no GPS":"GPS ok");
			View.findDrawableById("TemperatureTitle_dim").setText("");
			View.findDrawableById("Perception_bright").setText("");
			View.findDrawableById("PerceptionTitle_dim").setText("");
			View.findDrawableById("Wind_bright").setText("");
			View.findDrawableById("WindTitle_dim").setText("");
        }
        else
        {
        	var weatherInfo = new WeatherInfo();
        	weatherInfo.FromDictionary(App.getApp().getProperty("WeatherInfo"));
        	
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
			
			if (weatherInfo.City != null)
			{
				View.findDrawableById("City_dim").setText(weatherInfo.City);
			}
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
			View.findDrawableById("Battery2_dim").setText((batteryLevel % 10).format("%1d"));
		}
		
        // Call the parent onUpdate function to redraw the layout
        //
        View.onUpdate(dc);
    }
}
