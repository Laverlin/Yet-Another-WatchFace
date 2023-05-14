import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;

using Toybox.System as Sys;
// using Toybox.Time as Time;
// using Toybox.Time.Gregorian as Gregorian;

using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.Activity as Activity;
using Toybox.Math as Math;


// 
// import Toybox.System;

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
    
    // Returns the current day number
    //
    static function GetDOY(timeNow)
    {
        var gTimeNow = Gregorian.info(timeNow, Time.FORMAT_SHORT);	
        	
        var N1 = Math.floor(275 * gTimeNow.month / 9);
        var N2 = Math.floor((gTimeNow.month + 9) / 12);
        var N3 = (1 + Math.floor((gTimeNow.year - 4 * Math.floor(gTimeNow.year / 4) + 2) / 3));
        var DOY = N1 - (N2 * N3) + gTimeNow.day - 30;

        return DOY;
    }
    
    // Returns the next Sun event
    //
    static function GetNextSunEvent(DOY, lat, lon, tzOffset, dst, isRise)
    {
        var ZENITH = 90.51;

		var lonHour = lon / 15;
		var t = isRise 
			? DOY + ((6 - lonHour) / 24)
			: DOY + ((18 - lonHour) / 24);
        
		var M = (0.9856 * t) - 3.289;
		var L = M + (1.916 * Math.sin(Math.toRadians(M))) + (0.020 * Math.sin(Math.toRadians(2 * M))) + 282.634;
		L = norm360(L);		
		
		var RA = Math.toDegrees(Math.atan(0.91764 * Math.tan(Math.toRadians(L))));
		RA = norm360(RA);	
		RA = (RA + (((Math.floor( L/90)) - (Math.floor(RA/90))) * 90)) / 15;
		
		var sinDec = 0.39782 * Math.sin(Math.toRadians(L));
    	var cosDec = Math.cos(Math.asin(sinDec));
		var cosH = (Math.cos(Math.toRadians(ZENITH)) - (sinDec * Math.sin(Math.toRadians(lat)))) / (cosDec * Math.cos(Math.toRadians(lat)));
		
		if (cosH > 1 or cosH < -1) { return null; }
		
		var H = isRise 
			? (360 - Math.toDegrees(Math.acos(cosH))) / 15
			: (Math.toDegrees(Math.acos(cosH))) / 15;

		var UT = H + RA - (0.06571 * t) - 6.622 - lonHour;

		var localT = UT * 3600 + tzOffset + dst;
		if (localT >= 24 * 3600) {localT = localT - 24 * 3600;}
		if (localT < 0) {localT = localT + 24 * 3600;}
		
		return [localT.toNumber() % 86400 / 3600, localT.toNumber() % 3600 / 60, isRise];
    }
    
    
    static function norm360(num)
    {
    	if (num > 360) {return num - 360; }
    	if (num < 0 ) {return num + 360; }
    	return num;
    }
    
    static function GetMoonPhase(timeNow)
    {   	
    	var JD = timeNow.value().toDouble() / Gregorian.SECONDS_PER_DAY.toDouble() + 2440587.500d;
    	var IP = Normalize((JD.toDouble() - 2451550.1d) / 29.530588853d);
    	var Age = IP * 29.53d;
    	
    	var phase = 0;
    	if(      Age <  1.84566 ) {phase = 0;} // new moon
        else if( Age <  5.53699 ) {phase = 1;} // An evening crescent";
        else if( Age <  9.22831 ) {phase = 2;} // A first quarter";
        else if( Age < 12.91963 ) {phase = 3;} // A waxing gibbous";
        else if( Age < 16.61096 ) {phase = 4;} // A full moon";
        else if( Age < 20.30228 ) {phase = 5;} // A waning gibbous";
        else if( Age < 23.99361 ) {phase = 6;} // A Last quarter";
        else if( Age < 27.68493 ) {phase = 7;} // A Morning crescent";
        else                      {phase = 0;} // A new moon";

		
		IP = IP * 2d * Math.PI; // Convert phase to radians

        // calculate moon's distance
        //
        var DP = 2d * Math.PI * Normalize((JD - 2451562.2d) / 27.55454988d);

    	// calculate moon's ecliptic longitude
    	//
        var RP = Normalize((JD - 2451555.8d) / 27.321582241d);
        var LO = 360d * RP + 6.3d * Math.sin(DP) + 1.3d * Math.sin(2d * IP - DP) + 0.7d * Math.sin(2d * IP);

		var zodiac = 0;
    	if      (LO <  33.18) { zodiac = 0; } // Pisces
    	else if (LO <  51.16) { zodiac = 1; } // Aries"
	    else if (LO <  93.44) { zodiac = 2; } // Taurus"
	    else if (LO < 119.48) { zodiac = 3; } // Gemini"
	    else if (LO < 135.30) { zodiac = 4; } // Cancer"
	    else if (LO < 173.34) { zodiac = 5; } // Leo"
	    else if (LO < 224.17) { zodiac = 6; } // Virgo"
	    else if (LO < 242.57) { zodiac = 7; } // Libra"
	    else if (LO < 271.26) { zodiac = 8; } // Scorpio"
	    else if (LO < 302.49) { zodiac = 9; } // Sagittarius"
	    else if (LO < 311.72) { zodiac = 10; } // Capricorn"
	    else if (LO < 348.58) { zodiac = 11; } // Aquarius"
	    else                  { zodiac = 0; } //  Pisces"
		
    	return [phase, zodiac];
    }
    
    static function Normalize(value)
    {
    	var nValue = value - Math.floor(value);
    	if (nValue < 0)
    	{
    		nValue = nValue + 1;
    	}
    	return nValue;
    }
    
    
    
}
