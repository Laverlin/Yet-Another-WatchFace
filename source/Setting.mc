using Toybox.Application as App;

/// Wrapper class for stored properties
///
(:background)
class Setting
{
	static hidden var _lastKnownLocation = "lastKnownLocation";
	static hidden var _weatherInfo = "WeatherInfo";
	static hidden var _etz = "etz";
	static hidden var _isTest = "isTest";

    static hidden var _locationApiKey = "location-api-key";

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
		return App.getApp().getProperty(_weatherInfo);
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
		return App.getApp().getProperty(_locationApiKey); 
	}
	
	public static function SetLocationApiKey(apiKeyValue)
	{
		return App.getApp().setProperty(_locationApiKey, apiKeyValue); 
	}
	
	public static function SetAppVersion(appVersionValue)
	{
		return App.getApp().setProperty("AppVersion", appVersionValue); 
	}
	
	public static function GetIsShowCity()
	{
		return App.getApp().getProperty("IsShowCity");
	}
	
	public static function GetWindSystem()
	{
		return App.getApp().getProperty("windSystem");
	}
	
	public static function GetTempSystem()
	{
		return App.getApp().getProperty("tempSystem");
	}
	
	public static function GetDistSystem()
	{
		return App.getApp().getProperty("distSystem");
	}
	
	public static function GetIsTest()
	{
		return App.getApp().getProperty(_isTest);
	}
	public static function SetIsTest(isTest)
	{
		return App.getApp().setProperty(_isTest, isTest);
	}
	
}