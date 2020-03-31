using Toybox.Application as App;
using Toybox.Application.Storage as Storage;

/// Wrapper class for stored properties
///
(:background)
class Setting
{
	static hidden var _lastKnownLocation = "lastKnownLocation";
	static hidden var _etz = "etz";
	static hidden var _isTest = "isTest";
	
	static hidden var _baseCurrency = "base-currency";
	static hidden var _targetCurrency = "target-currency";
    static hidden var _locationApiKey = "location-api-key";
    static hidden var _exchangeRate = "exchange-rate-v2";
    static hidden var _isShowExchangeRate = "is-show-exchange";
	static hidden var _pulseField = "pulse-field";
	static hidden var _exchangeApiKey = "exchange-api-key";
	static hidden var _city = "city-v2";
	static hidden var _weather = "weather-v2";
	static hidden var _appVersion = "appVersion";
	static hidden var _conError = "conError";
	static hidden var _authError = "authError";
	static hidden var _deviceName = "device-name";
	static hidden var _watchServerApiToken = "server-api-token";
	static hidden var _weatherProvider = "weather-provider";
	static hidden var _weatherRefreshToken = "wr-token";

	public static function GetWeatherRefreshToken()
	{
		return App.getApp().getProperty(_weatherRefreshToken);
	}
	
	public static function SetWeatherRefreshToken(weatherRefreshToken)
	{
		App.getApp().setProperty(_weatherRefreshToken, weatherRefreshToken);
	}

	public static function GetWeather()
	{
		return App.getApp().getProperty(_weather);
	}
	
	public static function SetWeather(weather)
	{
		App.getApp().setProperty(_weather, weather);
	}
	
	public static function GetWeatherProvider()
	{
		var tmp = App.getApp().getProperty(_weatherProvider);
		return tmp != null ? tmp : 0;
	}
	
	public static function SetWeatherProvider(weatherProvider)
	{
		App.getApp().setProperty(_weatherProvider, weatherProvider);
	}
	
	public static function SetDeviceName(deviceNme)
	{
		//Storage.setValue(_deviceName, deviceNme);
		App.getApp().setProperty(_deviceName, deviceNme);
	}

	public static function GetDeviceName()
	{
		//return Storage.getValue(_deviceName);
		var tmp = App.getApp().getProperty(_deviceName);
		return tmp != null ? tmp : "unknown";
	}
	
	public static function GetWatchServerToken()
	{
		//return Storage.getValue(_watchServerApiToken);
		return App.getApp().getProperty(_watchServerApiToken);
	}
	
	public static function SetWatchServerToken(watchServerApiToken)
	{
		//Storage.setValue(_watchServerApiToken, watchServerApiToken);
		App.getApp().setProperty(_watchServerApiToken, watchServerApiToken);
	}	
	

	public static function GetConError()
	{
		//return Storage.getValue(_conError); 
		return App.getApp().getProperty(_conError);
	}
	
	public static function SetConError(conError)
	{
		//Storage.setValue(_conError, conError);
		App.getApp().setProperty(_conError, conError);	
	}
	

	

	
	public static function GetCity()
	{
		//return Storage.getValue(_city);
		return App.getApp().getProperty(_city);
	}
	
	public static function SetCity(city)
	{
		//Storage.setValue(_city, city);
		App.getApp().setProperty(_city, city);
	}
	
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
			
	public static function GetWeatherApiKey()
	{
		var waKey = App.getApp().getProperty("WeatherApiKey");
		return waKey != null ? waKey : ""; 
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
		//return Storage.getValue(_lastKnownLocation);
	}
	
	public static function SetLastKnownLocation(lastKnownLocation)
	{
		App.getApp().setProperty(_lastKnownLocation, lastKnownLocation);
		//Storage.setValue(_lastKnownLocation, lastKnownLocation);
	}
	
	public static function GetEtzId()
	{
		return App.getApp().getProperty("etzId");
	}
	
	public static function SetAppVersion(appVersionValue)
	{
		//Storage.setValue(_appVersion, appVersionValue);
		App.getApp().setProperty(_appVersion, appVersionValue); 
	}
	
	public static function GetAppVersion()
	{
		//return Storage.getValue(_appVersion); //, appVersionValue
		var appVersion = App.getApp().getProperty(_appVersion);
		return appVersion != null ? appVersion :"0.0"; 
	}
	
	public static function GetIsShowCity()
	{
		return App.getApp().getProperty("is-show-city");
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
	
	public static function GetAltimeterSystem()
	{
		return App.getApp().getProperty("altimeter-system");
	}
	
	public static function GetCityAlign()
	{
		return App.getApp().getProperty("city-align");
	}
	
	public static function GetAlarmAlign()
	{
		return App.getApp().getProperty("alarm-align");
	}
	
	public static function GetIsTest()
	{
		var isTest = App.getApp().getProperty(_isTest);
		return isTest != null ? isTest : false;
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
	
	public static function GetExchangeApiKey()
	{
		return App.getApp().getProperty(_exchangeApiKey);
	}
	public static function SetExchangeApiKey(apiKey)
	{
		App.getApp().setProperty(_exchangeApiKey, apiKey);
	}
	
	public static function GetBaseCurrencyId()
	{
		return App.getApp().getProperty("base-currency-id2");
	}
	
	public static function GetTargetCurrencyId()
	{
		return App.getApp().getProperty("target-currency-id2");
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
	
	public static function GetShowAlarm()
	{
		return App.getApp().getProperty("show-alarm");
	}
	
	public static function GetShowMessage()
	{
		return App.getApp().getProperty("show-message");
	}	
	
	public static function GetField(id)
	{
		return App.getApp().getProperty("field-" + id).toNumber();
	}
	
}