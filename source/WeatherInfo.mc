(:background)
class WeatherInfo
{
	var Temperature = 0;
	var WindSpeed = 0;
	var PerceptionProbability = 0;
	var Condition = "";
	var WeatherStatus = 0; // unknown
	var CityStatus = 0; // unknown
	var Location;
	var City = "";
	
	static function ToDictionary(weatherInfo)
	{
		return
		{
			"Temperature" => weatherInfo.Temperature, 
			"WindSpeed" => weatherInfo.WindSpeed, 
			"PerceptionProbability" => weatherInfo.PerceptionProbability, 
			"Condition" => weatherInfo.Condition, 
			"City" => weatherInfo.City,
			"WeatherStatus" => weatherInfo.WeatherStatus,
			"CityStatus" => weatherInfo.CityStatus
		};
	}
	
	static function FromDictionary(dictionary)
	{
		var weatherInfo = new WeatherInfo();
		try
		{
			weatherInfo.Temperature = dictionary["Temperature"];
			weatherInfo.WindSpeed = dictionary["WindSpeed"];
			weatherInfo.PerceptionProbability = dictionary["PerceptionProbability"];
			weatherInfo.Condition = dictionary["Condition"];
			weatherInfo.City = dictionary["City"];
			weatherInfo.WeatherStatus = dictionary["WeatherStatus"];
			weatherInfo.CityStatus = dictionary["CityStatus"];
		}
		catch(ex)
		{
			Sys.println("dictionary conversion error:" + ex.getErrorMessage());
			weatherInfo.Status = -1000;
		}
		return weatherInfo;
	}
}