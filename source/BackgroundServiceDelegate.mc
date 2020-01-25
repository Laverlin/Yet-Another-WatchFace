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
	hidden var _syncCounter = 0;
	hidden var _received = {}; 
	 
	function initialize() 
	{
		Sys.ServiceDelegate.initialize();
	}
	
    function onTemporalEvent() 
    {
    	try
    	{
	    	// Request Currency
	    	//
	    	if (Setting.GetIsShowExchangeRate())
			{
				RequestExchangeRate();
			}
	    
	    	// Request Location & weather
	    	//
	    	var location = Setting.GetLastKnownLocation();
	    	if (location != null)
	    	{
	    		RequestWeather(Setting.GetWeatherApiKey(), location);
	    	}

		}
		catch(ex)
		{
			Sys.println("temp event error: " + ex.getErrorMessage());
			_received.put("isErr", true);
			Background.exit(_received);
		}		
    }
    
    function RequestWeather(apiKey, location)
	{	
		var weatherProviders = ["OpenWeather", "DarkSky"];

		var versions = Lang.format("$1$.$2$", Sys.getDeviceSettings().firmwareVersion) + 
			Lang.format("&ciqv=$1$.$2$.$3$", Sys.getDeviceSettings().monkeyVersion);
			
		var provider = (Setting.GetWeatherProvider() == 1) 
			? Lang.format("&wapiKey=$1$&wp=$2$", [Setting.GetWeatherApiKey(), weatherProviders[Setting.GetWeatherProvider()]])
			: Lang.format("&wp=$1$", [weatherProviders[Setting.GetWeatherProvider()]]); 

		var url = Lang.format(
			//"https://ivan-b.com/garminapi/wf-service/weather?apiToken=$1$&lat=$2$&lon=$3$&did=$4$&v=$5$&fw=$6$&dname=$7$$8$", [
			"localhost:5051/api/YAFace/weather?apiToken=$1$&lat=$2$&lon=$3$&did=$4$&v=$5$&fw=$6$&dname=$7$$8$", [
			Setting.GetWatchServerToken(),
			location[0],
			location[1],
			Sys.getDeviceSettings().uniqueIdentifier,
			Setting.GetAppVersion(),
			versions,
			Setting.GetDeviceName(),
			provider]);			
			
		//Sys.println(" :: weather request " + url);

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
			//Sys.println("weather data: " + data + "\n code: " + responseCode);
		
			if (responseCode == 200)
			{
				_received.put("weather", {
					"temp" => data["temperature"].toFloat(),
					"wndSpeed" => data["windSpeed"].toFloat(),
					"precipitation" => data["precipProbability"].toFloat() * 100,
					"humidity" => data["humidity"].toFloat() * 100,
					"condition" => data["icon"]});
				_received.put("city", { 
					"City" => data["cityName"]});
			}
			else
			{
				_received.put("isErr", true);
			}
			
			if (responseCode == 403 || responseCode == 401)
			{
				_received.put("isAuthErr", true);
			}
			
			_syncCounter = _syncCounter - 1;
			if (_syncCounter == 0)
			{
				Background.exit(_received);
			}
		}
		catch(ex)
		{
			Sys.println("get weather error : " + ex.getErrorMessage());
			_received.put("isErr", true);
			Background.exit(_received);
		}
	}
	
	
	function RequestExchangeRate()
	{
		var url = Lang.format("https://api.exchangeratesapi.io/latest?base=$1$&symbols=$2$", [
			Setting.GetBaseCurrency(), 
			Setting.GetTargetCurrency()]);	
		 
		//Sys.println(" :: ex rate request: " + url);
		
		var options = {
        	:method => Comm.HTTP_REQUEST_METHOD_GET,
          	:responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
		};
		
		_syncCounter = _syncCounter + 1;
    	Comm.makeWebRequest(url, {}, options, method(:OnReceiveExchangeRate));
	}
	
	function OnReceiveExchangeRate(responseCode, data)
	{
		//Sys.println(" data = " + data);
		//Sys.println(" code = " + responseCode);
		try
		{
			if (responseCode == 200)
			{
				_received.put("exchange", {
					"ExchangeRate" => data["rates"][Setting.GetTargetCurrency()].toFloat()});
			}
			else
			{
				_received.put("isErr", true);
			}
			
			_syncCounter = _syncCounter - 1;
			if (_syncCounter == 0)
			{
				Background.exit(_received);
			}
		}
		catch(ex)
		{
			Sys.println("get ex rate error : " + ex.getErrorMessage());
			_received.put("isErr", true);
			Background.exit(_received);
		}
	}
}