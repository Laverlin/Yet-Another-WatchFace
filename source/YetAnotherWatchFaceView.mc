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
	 
    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    //
    function onLayout(dc) {
        //setLayout(Rez.Layouts.WatchFace(dc));
		setLayout(Rez.Layouts.MiddleDateLayout(dc));
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

        var timeNow = Gregorian.info(Time.now(), Time.FORMAT_LONG);
    	
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
