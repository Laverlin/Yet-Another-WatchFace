using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;

using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.Activity as Activity;

class WatchData
{
	// Return time and abbreviation of extra time-zone
    // parameters, curretTime, TimeZone 
    //
    static function GetTzTime(timeNow, extraTz)
    {
    	
        var localTime = Sys.getClockTime();
        var utcTime = timeNow.add(
        	new Time.Duration( - localTime.timeZoneOffset + localTime.dst));
        
        // by dfault return UTC time
        //
		if (extraTz == null)
		{
			return [Gregorian.info(utcTime, Time.FORMAT_MEDIUM), "UTC"];
		}
 
 		// find right time interval
 		//
        var index = 0;
        for (var i = 0; i < extraTz["Untils"].size(); i++)
        {
        	if (extraTz["Untils"][i] != null && extraTz["Untils"][i] > utcTime.value())
        	{
        		index = i;
        		break;
        	}
        }
        
        var extraTime = utcTime.add(new Time.Duration(extraTz["Offsets"][index] * -60));        
      
        return [Gregorian.info(extraTime, Time.FORMAT_MEDIUM), extraTz["Abbrs"][index]];
    }
    
    static function GetWatchInfo()
    {
    	var watchInfo = new WatchInfo();
    	watchInfo.Time = Time.now();
    	watchInfo.CurrentLocation = Activity.getActivityInfo().currentLocation;
    	
    	var deviceSetting = Sys.getDeviceSettings();
    	watchInfo.Is24Hour = deviceSetting.is24Hour;
    	watchInfo.ConnectionState = deviceSetting.phoneConnected;
    	
    	var info = ActivityMonitor.getInfo();
    	watchInfo.DistanceKm = info.distance.toFloat()/100000;
    	watchInfo.DistanceMi = info.distance.toFloat()/160934.4;
    	watchInfo.DistanceSteps = info.steps;
    	watchInfo.BatteryLevel = (Sys.getSystemStats().battery).toNumber();
    	
    	return watchInfo;
    }
}


class WatchInfo
{
	var Time;
	var Is24Hour;
	var CurrentLocation;
	var DistanceKm;
	var DistanceMi;
	var DistanceSteps;
	var ConnectionState;
	var BatteryLevel;
}