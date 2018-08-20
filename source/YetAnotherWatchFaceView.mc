using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;

class YetAnotherWatchFaceView extends Ui.WatchFace {

	hidden var _timeForegroundColor;
	hidden var _dayForegroundColor;
	hidden var _monthForegroundColor;
	hidden var _alternateTimeZone;
	//hidden var _altTzTitle = { -28800 => "PST", -21600 => "CST", -18000 => "EST", 0 => "UTC", 3600 => "CET"};
	hidden var _tzTitleDictionary; 
	 
    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    //
    function onLayout(dc) {
        //setLayout(Rez.Layouts.WatchFace(dc));
		setLayout(Rez.Layouts.MiddleDateLayout(dc));
		_tzTitleDictionary = Ui.loadResource(Rez.JsonData.tzTitleDictionary);
		UpdateSetting();
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    //
    function onShow() {

    }
    
    function UpdateSetting()
    {
	 	_timeForegroundColor = App.getApp().getProperty("TimeForegroundColor");
		_dayForegroundColor = App.getApp().getProperty("DayForegroundColor");
		_monthForegroundColor = App.getApp().getProperty("MonthForegroundColor");
		_alternateTimeZone = App.getApp().getProperty("AlternateTimeZone");
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
        var tzTitle = _tzTitleDictionary[_alternateTimeZone.toString()]; //_altTzTitle.get(_alternateTimeZone);
        if (tzTitle == null)
        {
        	tzTitle = "[" + (_alternateTimeZone/3600).toString() + "]";
        }
        viewAltTimeTitle.setText(tzTitle);

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
