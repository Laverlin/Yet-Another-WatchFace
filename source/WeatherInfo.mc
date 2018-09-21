(:background)
class WeatherInfo
{
	var Temperature = 0;
	var WindSpeed = 0;
	var PerceptionProbability = 0;
	var Condition = "";
	var Status = 0; // unknown
	var Location;
	var City = "";
	
	function ToDictionary()
	{
		return
		{
			"Temperature" => Temperature, 
			"WindSpeed" => WindSpeed, 
			"PerceptionProbability" => PerceptionProbability, 
			"Condition" => Condition, 
			"Status" => Status,
			"City" => City
		};
	}
	
	function FromDictionary(dictionary)
	{
		try
		{
			Temperature = dictionary["Temperature"];
			WindSpeed = dictionary["WindSpeed"];
			PerceptionProbability = dictionary["PerceptionProbability"];
			Condition = dictionary["Condition"];
			Status = dictionary["Status"];
			City = dictionary["City"];
		}
		catch(ex)
		{
			Sys.println("dictionary conversion error:" + ex.getErrorMessage());
			Status = -1000;
		}
	}
}