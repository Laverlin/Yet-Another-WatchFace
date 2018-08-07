using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;

class YetAnotherWatchFaceView extends Ui.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    //
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    //
    function onShow() {
    }
    
    // calls every second for partial update
    //
    function onPartialUpdate(dc)
    {
		
    }

    // Update the view
    //
    function onUpdate(dc) {

        var clockTime = Sys.getClockTime();

        // Update the view
        //
        var viewHour = View.findDrawableById("TimeHourLabel");
        viewHour .setColor(App.getApp().getProperty("ForegroundColor"));
        viewHour .setText(clockTime.hour.format("%02d"));
        
        var viewMinute = View.findDrawableById("TimeMinuteLabel");
        viewMinute.setColor(App.getApp().getProperty("ForegroundColor"));
        viewMinute.setText(clockTime.min.format("%02d"));
        
        var viewSecond = View.findDrawableById("TimeSecondLabel");
        viewSecond.setColor(App.getApp().getProperty("ForegroundColor"));
        viewSecond.setText(clockTime.sec.format("%02d"));        
        
        var viewDivider = View.findDrawableById("divider");
        viewDivider.setLineColor(App.getApp().getProperty("ForegroundColor"));

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
