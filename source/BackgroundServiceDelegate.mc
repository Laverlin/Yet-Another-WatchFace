using Toybox.Background;
using Toybox.System as Sys;
using Toybox.Activity as Activity;
using Toybox.Communications as Comm;
using Toybox.Position as Position;
using Toybox.Application as App;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;

// The Service Delegate is the main entry point for background processes
// our onTemporalEvent() method will get run each time our periodic event
// is triggered by the system.
//
(:background)
class BackgroundServiceDelegate extends Toybox.System.ServiceDelegate 
{
	var _time;
			
	function initialize() 
	{
		Sys.ServiceDelegate.initialize();
	}
	
    function onTemporalEvent() 
    {
		RequestWeather();
    }
    
    function RequestWeather()
	{
		// get unix epoch 
		//
		var tz = new Time.Duration(Sys.getClockTime().timeZoneOffset * -1);
		var epoch = Time.now().add(tz);
		var gTime = Gregorian.info(epoch, Time.FORMAT_MEDIUM);
		_time = gTime.month + "." + gTime.day + " " + gTime.hour + ":" + gTime.min + ":" + gTime.sec;
		
		// get gps
		//
		var location = App.getApp().getProperty("lastKnownLocation");
		if (location == null)
		{
			Sys.println(_time + " :: location unknown");
			return;
		}
		
		var url = Lang.format("$1$/$2$/$3$,$4$,$5$?exclude=minutely,hourly,daily,flags,alerts&units=si", [
			"https://api.darksky.net/forecast",
			App.getApp().getProperty("WeatherApiKey"),
			location[0],
			location[1],
			epoch.value()]);  
			
		Sys.println(_time + " :: request " + url);

        var options = {
          :method => Comm.HTTP_REQUEST_METHOD_GET,
          :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

       Comm.makeWebRequest(url, {}, options, method(:OnReceiveWeather));
	}  
	
	function OnReceiveWeather(responseCode, data)
	{
	   // Sys.println(_time + " :: response code: " + responseCode + ", data :: " + data);
	    
	    var weatherInfo = new WeatherInfo();
		if (responseCode == 200)
		{
			weatherInfo.Temperature = data["currently"]["temperature"].toFloat();
			weatherInfo.WindSpeed = data["currently"]["windSpeed"].toFloat() * 1.94384;
			weatherInfo.PerceptionProbability = data["currently"]["precipProbability"].toFloat() * 100;
			weatherInfo.Condition = data["currently"]["icon"];
			weatherInfo.City = parseCity(data["timezone"]);
			weatherInfo.Status = 1; //OK
		}
		else
		{
			weatherInfo.Status = responseCode;
		}
		Background.exit(weatherInfo.ToDictionary());
	}
	
	hidden function parseCity(city)
	{
		var dindex = city.find("/");
		return (dindex == 0) 
			? city
			: city.substring(dindex + 1, city.length());
	}
}