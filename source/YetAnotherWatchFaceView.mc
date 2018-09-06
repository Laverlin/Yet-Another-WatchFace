using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.Activity as Activity;

class YetAnotherWatchFaceView extends Ui.WatchFace {

	var MonthForegroundColor = Gfx.COLOR_BLUE;
	
	hidden var _timeForegroundColor;
	hidden var _dayForegroundColor;
	hidden var _monthForegroundColor;
	hidden var _alternateTimeZone;
	hidden var _tzTitleDictionary; 
	hidden var _weatherApiKey;
	hidden var _weatherApiUrl;
	hidden var _conditionIcons;
	
	hidden var _weatherInfo = new WeatherInfo();
	
    function initialize() 
    {
        WatchFace.initialize();
    }

    // Load your resources here
    //
    function onLayout(dc) {
        //setLayout(Rez.Layouts.WatchFace(dc));
		setLayout(Rez.Layouts.MiddleDateLayout(dc));
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

    }
    
    function UpdateWeatherInfo(weatherInfo)
    {
    	_weatherInfo = weatherInfo;
    }
    
    function UpdateSetting()
    {
	 	_timeForegroundColor = App.getApp().getProperty("TimeForegroundColor");
		_dayForegroundColor = App.getApp().getProperty("DayForegroundColor");
		_monthForegroundColor = App.getApp().getProperty("MonthForegroundColor");
		_alternateTimeZone = App.getApp().getProperty("AlternateTimeZone");
		_weatherApiUrl = "https://api.darksky.net/forecast";
		_weatherApiKey = App.getApp().getProperty("WeatherApiKey");
		
		MonthForegroundColor = _monthForegroundColor;
    }
    
    // calls every second for partial update
    //
    function onPartialUpdate(dc)
    {
    	var clockTime = Sys.getClockTime();
    	
    	var viewSecond = View.findDrawableById("TimeSecondLabel");
     	viewSecond.setText(clockTime.sec.format("%02d"));
		dc.setClip(viewSecond.locX - viewSecond.width, viewSecond.locY, viewSecond.width + 1, viewSecond.height);
		View.onUpdate(dc);
        
		var chr = Activity.getActivityInfo().currentHeartRate;
		if (chr != null)
		{
			var viewPulse = View.findDrawableById("PulseLabel");
			viewPulse.setText(chr.toString());
			dc.setClip(viewPulse.locX, viewPulse.locY, viewPulse.locX + viewPulse.width + 1, viewPulse.height);
			View.onUpdate(dc);
		}
        dc.clearClip();
    }

    // Update the view
    //
    function onUpdate(dc) {

		var timeNowValue = Time.now();
        var timeNow = Gregorian.info(timeNowValue, Time.FORMAT_MEDIUM);
    	
    	var viewDivider = View.findDrawableById("divider");
        viewDivider.setLineColor(_timeForegroundColor);
    	
        // Update Time
        //
        var viewHour = View.findDrawableById("TimeHourLabel");
        viewHour.setColor(_timeForegroundColor);
        viewHour.setText(timeNow.hour.format("%02d"));
        
        var viewMinute = View.findDrawableById("TimeMinuteLabel");
        viewMinute.setColor(_timeForegroundColor);
        viewMinute.setText(timeNow.min.format("%02d"));
        
        var viewSecond = View.findDrawableById("TimeSecondLabel");
        viewSecond.setColor(_timeForegroundColor);
        viewSecond.setText(timeNow.sec.format("%02d"));        
        
        // Update date
        //
        var viewWeekDay = View.findDrawableById("TimeWeekDayLabel");
        viewWeekDay.setColor(_dayForegroundColor);
        viewWeekDay.setText(timeNow.day_of_week.toLower());
        
        var viewMonth = View.findDrawableById("TimeMonthLabel");
        viewMonth.setColor(_monthForegroundColor);
        viewMonth.setText(timeNow.month.toLower());
        
        var viewDay = View.findDrawableById("TimeDayLabel");
        viewDay.setColor(_dayForegroundColor);
        viewDay.setText(timeNow.day.format("%02d"));
        
        // Update Alternate Time
        //
        var localTimeValue = Sys.getClockTime();
        var localTz = new Time.Duration( - localTimeValue.timeZoneOffset + localTimeValue.dst);
        var alternateTz = new Time.Duration(_alternateTimeZone);
        var alternateTimeValue = timeNowValue.add(localTz).add(alternateTz);
        var alternateTime = Gregorian.info(alternateTimeValue, Time.FORMAT_MEDIUM);

        var viewAltTime = View.findDrawableById("OtherTimeLabel");
        viewAltTime.setColor(_dayForegroundColor);
        viewAltTime.setText(alternateTime.hour.format("%02d") + ":" + alternateTime.min.format("%02d"));

        var viewAltTimeTitle = View.findDrawableById("OtherTimeTitleLabel");
        viewAltTimeTitle.setColor(_monthForegroundColor);
        var tzTitle = _tzTitleDictionary[_alternateTimeZone.toString()]; 

        viewAltTimeTitle.setText(tzTitle);
        
        // get ActivityMonitor info
        //
		var info = ActivityMonitor.getInfo();
		var distance = info.distance.toFloat()/10000;
		
        var viewDistance = View.findDrawableById("DistLabel");
        viewDistance.setColor(_dayForegroundColor);
        viewDistance.setText(distance.format("%2.1f"));
        
        var viewDistanceTitle = View.findDrawableById("DistTitleLabel");
        viewDistanceTitle.setColor(_monthForegroundColor);
        
        var viewPulse = View.findDrawableById("PulseLabel");
        viewPulse.setColor(_dayForegroundColor);
        
        var viewPulseTitle = View.findDrawableById("PulseTitleLabel");
        viewPulseTitle.setColor(_monthForegroundColor);
        
        // Weather data
        //
		var weather = Lang.format("$1$", [_weatherInfo.Temperature.format("%2.1f")]);
		var perception = Lang.format("$1$%", [_weatherInfo.PerceptionProbability.format("%2d")]);
        
		var viewWeather = View.findDrawableById("WeatherLabel");
		viewWeather.setColor(_dayForegroundColor);
		viewWeather.setText(weather);
		var viewWeatherTitle = View.findDrawableById("WeatherLabelTitle");
		viewWeatherTitle.setColor(_monthForegroundColor);
		viewWeatherTitle.locX = viewWeather.locX + dc.getTextWidthInPixels(weather, Gfx.FONT_TINY) + 1;
		
		var viewPerception = View.findDrawableById("PerceptionLabel");
		viewPerception.setColor(_dayForegroundColor);
		viewPerception.setText(perception);
		
		var viewWind = View.findDrawableById("WindLabel");
		viewWind.setColor(_dayForegroundColor);
		var wind = Lang.format("$1$", [_weatherInfo.WindSpeed.format("%2.1f")]);
		viewWind.setText(wind);		
		
		var viewWindTitle = View.findDrawableById("WindTitle");
		viewWindTitle.setColor(_monthForegroundColor);
		viewWindTitle.locX = viewWind.locX + dc.getTextWidthInPixels(wind, Gfx.FONT_TINY) + 1;

		var viewCondition = View.findDrawableById("ConditionLabel");
		viewCondition.setColor(_timeForegroundColor);
		var icon = _conditionIcons[_weatherInfo.Condition];
		if (icon != null)
		{
			viewCondition.setText(icon);
		}

		// watch status
		//
		var connectionState = Sys.getDeviceSettings().phoneConnected;
		var viewBt = View.findDrawableById("BluetoothLabel");
		viewBt.setColor(_monthForegroundColor);
		viewBt.setText(connectionState ? "a" : "b");
		
		var batteryLevel = (Sys.getSystemStats().battery).toNumber();
		View.findDrawableById("BatteryLabel1").setText((batteryLevel % 10).format("%1d"));
		batteryLevel = batteryLevel / 10;
		if (batteryLevel == 10 )
		{
			View.findDrawableById("BatteryLabel3").setText("1");
			View.findDrawableById("BatteryLabel2").setText("0");
		}
		else
		{
			View.findDrawableById("BatteryLabel3").setText("");
			View.findDrawableById("BatteryLabel2").setText((batteryLevel % 10).format("%1d"));
		}
		for (var i=0; i < 4; i++)
		{
			View.findDrawableById("BatteryLabel" + i).setColor(_monthForegroundColor);
		}
		
		
        // Call the parent onUpdate function to redraw the layout
        //
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    //
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    //
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    //
    function onEnterSleep() {
    }

}
