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
	hidden var _weatherInfo;
	hidden var _syncCounter = 0;
	hidden var _location;
	 
	function initialize() 
	{
		Sys.ServiceDelegate.initialize();
	}
	
    function onTemporalEvent() 
    {
    	try
    	{
	    	// init WeatherInfo object which will stor and pass data to the main app
	    	//
	    	var weatherData = Setting.GetWeatherInfo();
	    	if (weatherData != null)
	    	{
	    		_weatherInfo = WeatherInfo.FromDictionary(weatherData);
	    		_weatherInfo.ExchangeRate = Setting.GetExchangeRate();
	    	}
	    	else
	    	{
	    		_weatherInfo = new WeatherInfo();
	    	}
	    	    
	    	// Request Currency
	    	//
	    	if (Setting.GetIsShowExchangeRate())
			{
				RequestExchangeRate();
			}
	    
	    	_location = Setting.GetLastKnownLocation();
	    	var apiKey = Setting.GetWeatherApiKey();
	    	
	    	if (_location == null || _location.size() != 2)
	    	{
	    		Sys.println("location issue ");
	    		return;
	    	}
	    	
			// Request Weather
			//
	    	if (apiKey != null && apiKey.length() > 0)
	    	{
				RequestWeather(apiKey, _location);
			}
			
			// Request Location
			//
			if (Setting.GetIsShowCity())
			{
				// avoid unnecessary web requests (location name does not change if location the same)
				// 
				if(_weatherInfo.Location != null && 
					_location[0] == _weatherInfo.Location[0] && 
					_location[1] == _weatherInfo.Location[1])
				{
					return;
				}
				RequestLocation(_location);
			}
		}
		catch(ex)
		{
			Sys.println("temp event error: " + ex.getErrorMessage());
		}		
    }
    
    function RequestWeather(apiKey, location)
	{
		var url = Lang.format("$1$/$2$/$3$,$4$?exclude=minutely,hourly,daily,flags,alerts&units=si", [
			Setting.GetWeatherApiUrl(),
			apiKey,
			location[0],
			location[1]]);  
			
		//Sys.println(" :: request " + url);

        var options = {
          :method => Comm.HTTP_REQUEST_METHOD_GET,
          :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

		_syncCounter = _syncCounter + 1;
    	Comm.makeWebRequest(url, {}, options, method(:OnReceiveWeather));
	}  
	
	function OnReceiveWeather(responseCode, data)
	{
		try
		{
			if (responseCode == 200)
			{
				_weatherInfo.Temperature = data["currently"]["temperature"].toFloat();
				_weatherInfo.WindSpeed = data["currently"]["windSpeed"].toFloat();
				_weatherInfo.PerceptionProbability = data["currently"]["precipProbability"].toFloat() * 100;
				_weatherInfo.Condition = data["currently"]["icon"];
				_weatherInfo.WeatherStatus = 1; //OK
			}
		}
		catch(ex)
		{
			Sys.println("get weather error : " + ex.getErrorMessage());
		}
		
		_syncCounter = _syncCounter - 1;
		if (_syncCounter == 0)
		{
			Background.exit(WeatherInfo.ToDictionary(_weatherInfo));
		}
	}
	
	function RequestLocation(location)
	{
		var url = Lang.format(
			"https://dev.virtualearth.net/REST/v1/Locations/$1$,$2$?o=json&includeEntityTypes=populatedPlace&key=$3$", [
			location[0],
			location[1],
			Setting.GetLocationApiKey()]);  
			
		//Sys.println(" :: request2 " + url);	
			
        var options = {
          :method => Comm.HTTP_REQUEST_METHOD_GET,
          :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

		_syncCounter = _syncCounter + 1;
    	Comm.makeWebRequest(url, {}, options, method(:OnReceiveLocation));	
	}
	
	function OnReceiveLocation(responseCode, data)
	{
		//Sys.println("loc data" + data);
		try
		{
			if (responseCode == 200)
			{
				var cityName = data["resourceSets"][0]["resources"][0]["name"];
				_weatherInfo.City = cityName;
				_weatherInfo.Location = _location;
				_weatherInfo.CityStatus = 1; //OK
			}
		}
		catch (ex)
		{
			Sys.println("get location error : " + ex.getErrorMessage());
		}
				
		_syncCounter = _syncCounter - 1;
		if (_syncCounter == 0)
		{
			Background.exit(WeatherInfo.ToDictionary(_weatherInfo));
		}
	}
	
	function RequestExchangeRate()
	{
		var url = Lang.format("http://free.currencyconverterapi.com/api/v6/convert?q=$1$_$2$&compact=y", [
			Setting.GetBaseCurrency(), 
			Setting.GetTargetCurrency()]
		);
		 
		//Sys.println(" :: request3 " + url);
		
		var options = {
        	:method => Comm.HTTP_REQUEST_METHOD_GET,
          	:responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
		};
		
		_syncCounter = _syncCounter + 1;
    	Comm.makeWebRequest(url, {}, options, method(:OnReceiveExchangeRate));
	}
	
	function OnReceiveExchangeRate(responseCode, data)
	{
		//	Sys.println(" data = " + data);
		try
		{
			if (responseCode == 200)
			{
				_weatherInfo.ExchangeRate = 
					data[Lang.format("$1$_$2$", [Setting.GetBaseCurrency(), Setting.GetTargetCurrency()])]["val"]
					.toFloat();
			}
		}
		catch(ex)
		{
			Sys.println("get ex rate error : " + ex.getErrorMessage());
		}
		
		_syncCounter = _syncCounter - 1;
		if (_syncCounter == 0)
		{
			Background.exit(WeatherInfo.ToDictionary(_weatherInfo));
		}
	}
}