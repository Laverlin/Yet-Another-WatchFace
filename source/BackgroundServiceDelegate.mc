using Toybox.Background;
using Toybox.System as Sys;
using Toybox.Communications as Comm;
using Toybox.Application as App;
using Toybox.Lang as Lang;

// The Service Delegate is the main entry point for background processes
// our onTemporalEvent() method will get run each time our periodic event
// is triggered by the system.
//
(:background)
class BackgroundServiceDelegate extends Sys.ServiceDelegate 
{
	hidden var _received = {}; 
	 
	function initialize() 
	{
		Sys.ServiceDelegate.initialize();
	}
	
    function onTemporalEvent() 
    {
    	try
    	{
   	    	// Request update if one of the remote services displayed
	    	//
	    	//var location = Setting.GetLastKnownLocation();
	    	if (Setting.GetIsShowExchangeRate()
	    		|| Setting.GetIsShowCity()
	    		|| Setting.GetIsShowWeather())
	    	{
	    		RequestUpdate();
	    	}

		}
		catch(ex)
		{
			Sys.println("temp event error: " + ex.getErrorMessage());
			_received.put("isErr", true);
			Background.exit(_received);
		}		 
    }
    
    
    function RequestUpdate()
    {
		var weatherProviders = ["OpenWeather", "AppleDarkSky"];
		var weatherProvider = Setting.GetWeatherProvider();
		var location = Setting.GetLastKnownLocation();

		var versionsParam = Lang.format("&fw=$1$.$2$", Sys.getDeviceSettings().firmwareVersion) 
			+ Lang.format("&ciqv=$1$.$2$.$3$", Sys.getDeviceSettings().monkeyVersion);
			
		var providerParam = Lang.format("&wp=$1$", [weatherProviders[weatherProvider]]);
		
		var locationParam = (location != null)
			? Lang.format("&lat=$1$&lon=$2$", [location[0], location[1]])
			: "";
		
		var deviceParam = Lang.format("&did=$1$&dn=$2$&av=$3$", 
			[Sys.getDeviceSettings().uniqueIdentifier, Setting.GetDeviceName(), Setting.GetAppVersion()]);
			
		var currencyParam = (Setting.GetIsShowExchangeRate())
			? Lang.format("&bc=$1$&tc=$2$", [Setting.GetBaseCurrency(), Setting.GetTargetCurrency()])
			: "";

		var url = Lang.format(
			"https://ivan-b.com/watch-api/v2/YAFace?apiToken=$1$$2$$3$$4$$5$$6$", [
			//"https://localhost:7290/api/v2/YAFace?apiToken=test-token$2$$3$$4$$5$$6$", [
			Setting.GetWatchServerToken(),
			deviceParam,
			locationParam,
			providerParam,
			currencyParam,
			versionsParam]);
			
        var options = {
          :method => Comm.HTTP_REQUEST_METHOD_GET,
          :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

    	Comm.makeWebRequest(url, {}, options, method(:OnReceiveUpdate));    	
    }
    
    
    function OnReceiveUpdate(responseCode as Lang.Number, data as Null or Lang.Dictionary or Lang.String) as Void
	{
		try
		{
			if (responseCode == 200)
			{
				_received = data;
			}
			else
			{
				_received.put("isErr", true);
			}

			Background.exit(_received);
		}
		catch(ex)
		{
			Sys.println("get data error : " + ex.getErrorMessage());
			_received.put("isErr", true);
			Background.exit(_received);
		}
	}
}