using Toybox.Application as App;

/// Wrapper class for stored properties
///
(:background)
class Setting
{
	static hidden var _lastKnownLocation = "lastKnownLocation";
	static hidden var _weatherInfo = "WeatherInfo";
	static hidden var _etz = "etz";
	
	public static function GetTimeColor()
	{
		return App.getApp().getProperty("TimeColor");
	}
	
	public static function GetBackgroundColor()
	{
		return App.getApp().getProperty("BackgroundColor");
	}
	
	public static function GetBrightColor()
	{
		return App.getApp().getProperty("BrightColor");
	}
	
	public static function GetDimColor()
	{
		return App.getApp().getProperty("DimColor");
	}
	
	public static function GetWeatherApiUrl()
	{
		return "https://api.darksky.net/forecast";
	}
	
	public static function GetWeatherApiKey()
	{
		return App.getApp().getProperty("WeatherApiKey");
	}
	
	public static function GetExtraTimeZone()
	{
		return App.getApp().getProperty(_etz);
	}
	
	public static function SetExtraTimeZone(etz)
	{
		App.getApp().setProperty(_etz, etz);
	}
	
	public static function GetLastKnownLocation()
	{
		return App.getApp().getProperty(_lastKnownLocation);
	}
	
	public static function SetLastKnownLocation(lastKnownLocation)
	{
		App.getApp().setProperty(_lastKnownLocation, lastKnownLocation);
	}
	
	public static function GetWeatherInfo()
	{
		App.getApp().getProperty(_weatherInfo);
	}
	
	public static function SetWeatherInfo(weatherInfo)
	{
		App.getApp().setProperty(_weatherInfo, weatherInfo);
	}
	
	public static function GetEtzId()
	{
		return App.getApp().getProperty("etzId");
	}
	
	public static function GetLocationApiKey()
	{
		return "AnktcjcJZim7taMic5TNx7rovRDXAVyof_wvXxCWYJDU-c7MgON9bu6KHmHpi0Tv";
	}
	
	public static function GetIsShowCity()
	{
		return App.getApp().getProperty("IsShowCity");
	}
	
}