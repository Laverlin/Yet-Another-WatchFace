using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;

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
}