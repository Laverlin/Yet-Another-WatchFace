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
		var lastWeather = App.getApp().getProperty("WeatherInfo");
		if (lastWeather != null)
		{
			_weatherInfo.FromDictionary(App.getApp().getProperty("WeatherInfo"));
		}
	}
	
    function onTemporalEvent() 
    {
    	Sys.println("on event");
		RequestWeather();
    }
    
    function RequestWeather()
	{
		// get unix epoch 
		//
		var tz = new Time.Duration(Sys.getClockTime().timeZoneOffset*-1);
		var epoch = Time.now().add(tz);
		
		// get gps
		//
		var curLoc = Activity.getActivityInfo().currentLocation;
		if (curLoc == null) {return;}
		var location = curLoc.toDegrees();

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
			_weatherInfo.WindSpeed = data["currently"]["windSpeed"].toFloat();
			_weatherInfo.PerceptionProbability = data["currently"]["precipProbability"].toFloat()*100;
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

(:background)
class WeatherInfo
{
	var Temperature = 0;
	var WindSpeed = 0;
	var PerceptionProbability = 0;
	var Condition = "";
	var Status = 0;
	
	function ToDictionary()
	{
		return
		{
			"Temperature" => Temperature, 
			"WindSpeed" => WindSpeed, 
			"PerceptionProbability" => PerceptionProbability, 
			"Condition" => Condition, 
			"Status" => Status 
		};
	}
	
	function FromDictionary(dictionary)
	{
		Temperature = dictionary["Temperature"];
		WindSpeed = dictionary["WindSpeed"];
		PerceptionProbability = dictionary["PerceptionProbability"];
		Condition = dictionary["Condition"];
		Status = dictionary["Status"];
	}
}