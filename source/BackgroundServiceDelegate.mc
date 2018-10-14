using Toybox.Background;
using Toybox.System as Sys;
using Toybox.Communications as Comm;
using Toybox.Application as App;

// The Service Delegate is the main entry point for background processes
// our onTemporalEvent() method will get run each time our periodic event
// is triggered by the system.
//
(:background)
class BackgroundServiceDelegate extends Sys.ServiceDelegate 
{
	hidden var _weatherInfo = new WeatherInfo();
	hidden var _syncCounter = 0;
	 
	function initialize() 
	{
		Sys.ServiceDelegate.initialize();
	}
	
    function onTemporalEvent() 
    {
    	var location = Setting.GetLastKnownLocation();
    	var apiKey = Setting.GetWeatherApiKey();
    	
    	if (location == null)
    	{
    		return;
    	}
    	
    	if (apiKey == null || apiKey.length() == 0)
    	{
    		_syncCounter = 1;
			RequestLocation(location);
		}
		else
		{
    		_syncCounter = 0;
			RequestWeather(apiKey, location);
			RequestLocation(location);
		}
    }
    
    function RequestWeather(apiKey, location)
	{
		var url = Lang.format("$1$/$2$/$3$,$4$?exclude=minutely,hourly,daily,flags,alerts&units=si", [
			Setting.GetWeatherApiUrl(),
			apiKey,
			location[0],
			location[1]]);  
			
		Sys.println(" :: request " + url);

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
			_weatherInfo.WeatherStatus = 1; //OK
		}
		else
		{
			_weatherInfo.Status = responseCode;
		}
		
		_syncCounter = _syncCounter + 1;
		if (_syncCounter == 2)
		{
			Background.exit(WeatherInfo.ToDictionary(_weatherInfo));
		}
	}
	
	function RequestLocation(location)
	{
		var url = Lang.format("https://dev.virtualearth.net/REST/v1/Locations/$1$,$2$?o=json&includeEntityTypes=populatedPlace&key=$3$", [
			location[0],
			location[1],
			Setting.GetLocationApiKey()]);  
			
		//Sys.println(" :: request2 " + url);	
			
        var options = {
          :method => Comm.HTTP_REQUEST_METHOD_GET,
          :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

       Comm.makeWebRequest(url, {}, options, method(:OnReceiveLocation));	
	}
	
	function OnReceiveLocation(responseCode, data)
	{
		if (responseCode == 200)
		{
			var location = data["resourceSets"][0]["resources"][0]["name"];
			_weatherInfo.City = location;
			_weatherInfo.CityStatus = 1; //OK
		}
		
		_syncCounter = _syncCounter + 1;
		if (_syncCounter == 2)
		{
			Background.exit(WeatherInfo.ToDictionary(_weatherInfo));
		}
	}

}