using Toybox.Background;
using Toybox.System as Sys;
using Toybox.Activity as Activity;
using Toybox.Communications as Comm;
using Toybox.Position as Position;
using Toybox.Application as App;

// The Service Delegate is the main entry point for background processes
// our onTemporalEvent() method will get run each time our periodic event
// is triggered by the system.
//
(:background)
class BackgroundServiceDelegate extends Toybox.System.ServiceDelegate 
{
	var _weatherInfo = new WeatherInfo();
			
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
		
		// get gps
		//
		var activityLocation = Activity.getActivityInfo().currentLocation;
		if (activityLocation == null) 
		{
			return;
		}
		var location = activityLocation.toDegrees();

		var url = Lang.format("$1$/$2$/$3$,$4$,$5$?exclude=minutely,hourly,daily,flags,alerts&units=si", [
			"https://api.darksky.net/forecast",
			App.getApp().getProperty("WeatherApiKey"),
			location[0],
			location[1],
			epoch.value()]);  

        var options = {
          :method => Comm.HTTP_REQUEST_METHOD_GET,
          :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

       Comm.makeWebRequest(url, {}, options, method(:OnReceiveWeather));
	}  
	
	function OnReceiveWeather(responseCode, data)
	{
		if (responseCode == 200)
		{
			_weatherInfo.Temperature = data["currently"]["temperature"].toFloat();
			_weatherInfo.WindSpeed = data["currently"]["windSpeed"].toFloat() * 1.94384;
			_weatherInfo.PerceptionProbability = data["currently"]["precipProbability"].toFloat() * 100;
			_weatherInfo.Condition = data["currently"]["icon"];
			_weatherInfo.Status = 1;
		}
		else
		{
			_weatherInfo.Status = responseCode;
		}
		Background.exit(_weatherInfo.ToDictionary());
	}
}