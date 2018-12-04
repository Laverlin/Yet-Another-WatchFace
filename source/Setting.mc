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
	
	static hidden var _baseCurrency = "base-currency";
	static hidden var _targetCurrency = "target-currency";
    static hidden var _locationApiKey = "location-api-key";
    static hidden var _exchangeRate = "exchange-rate";
    static hidden var _isShowExchangeRate = "is-show-exchange";
	static hidden var _pulseField = "pulse-field";
	
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
	
	public static function GetIsShowExchangeRate()
	{
		return App.getApp().getProperty(_isShowExchangeRate);
	}
	
	public static function SetIsShowExchangeRate(isShowExchange)
	{
		App.getApp().setProperty(_isShowExchangeRate, isShowExchange);
	}	
	
	public static function GetPulseField()
	{
		return App.getApp().getProperty(_pulseField);
	}
	
	public static function SetPulseField(pulseField)
	{
		App.getApp().setProperty(_pulseField, pulseField);
	}
	
	public static function GetBaseCurrency()
	{
		return App.getApp().getProperty(_baseCurrency);
	}
	
	public static function GetTargetCurrency()
	{
		return App.getApp().getProperty(_targetCurrency);
	}
	
	public static function SetBaseCurrency(baseCurrency)
	{
		App.getApp().setProperty(_baseCurrency, baseCurrency);
	}
	public static function SetTargetCurrency(targetCurrency)
	{
		App.getApp().setProperty(_targetCurrency, targetCurrency);
	}
	
	public static function GetBaseCurrencyId()
	{
		return App.getApp().getProperty("base-currency-id");
	}
	
	public static function GetTargetCurrencyId()
	{
		return App.getApp().getProperty("target-currency-id");
	}
	
	public static function GetIsShowWeather()
	{
		return App.getApp().getProperty("is-show-weather");
	}
	
	public static function GetIsShowSeconds()
	{
		return App.getApp().getProperty("is-show-seconds");
	}
	
	public static function SetExchangeRate(rate)
	{
		App.getApp().setProperty(_exchangeRate, rate);
	}
	
	public static function GetExchangeRate()
	{
		return App.getApp().getProperty(_exchangeRate);
	}
	
	public static function GetField(id)
	{
		return App.getApp().getProperty("field-" + id).toNumber();
	}
	
}