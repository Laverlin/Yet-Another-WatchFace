using Toybox.Application as App;
using Toybox.Application.Storage as Storage;
using Toybox.System as Sys;
using Toybox.Application.Properties as Properties;
using Toybox.Application.Storage;
using Toybox.WatchUi as Ui;

/// Wrapper class for stored properties
///
(:background)
class Setting
{
	static hidden var _lastKnownLocation = "lastKnownLocation";
	static hidden var _etz = "etz";
	
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
	static hidden var _dateOrder = "date-order";
	static hidden var _bottomLayout = "bottom-line";
	static hidden var _isShowMoon = "is-show-moon";

	public static function GetShowMoon()
	{
		return GetValue(_isShowMoon);
	}
	
	public static function GetBottomLayout()
	{
		return GetValue(_bottomLayout);
	}
	
	public static function GetDateOrder()
	{
		return GetValue(_dateOrder);
	}

	public static function GetWeatherRefreshToken()
	{
		return GetTmpValue(_weatherRefreshToken);
	}
	
	public static function SetWeatherRefreshToken(weatherRefreshToken)
	{
		SetTmpValue(_weatherRefreshToken, weatherRefreshToken);
	}

	public static function GetWeather()
	{
		return GetTmpValue(_weather);
	}
	
	public static function SetWeather(weather)
	{
		SetTmpValue(_weather, weather);
	}
	
	public static function GetWeatherProvider()
	{
		return GetValue(_weatherProvider);
	}
	
	public static function SetWeatherProvider(weatherProvider)
	{
		SetTmpValue(_weatherProvider, weatherProvider);
	}
	
	public static function SetDeviceName(deviceNme)
	{	
		SetTmpValue(_deviceName, deviceNme);
	}

	public static function GetDeviceName()
	{
		var tmp = GetTmpValue(_deviceName);
		return tmp != null ? tmp : "unknown";
	}
	
	public static function GetWatchServerToken()
	{
		return GetTmpValue(_watchServerApiToken);
	}
	
	public static function SetWatchServerToken(watchServerApiToken)
	{
		SetTmpValue(_watchServerApiToken, watchServerApiToken);
	}	
	
	public static function GetConError()
	{
		return GetTmpValue(_conError);
	}
	
	public static function SetConError(conError)
	{
		SetTmpValue(_conError, conError);	
	}
	
	public static function GetCity()
	{
		return GetTmpValue(_city);
	}
	
	public static function SetCity(city)
	{
		SetTmpValue(_city, city);
	}
	
	public static function GetTimeColor()
	{
		return GetValue("TimeColor");
	}
	
	public static function GetBackgroundColor()
	{
		return GetValue("BackgroundColor");
	}
	
	public static function GetBrightColor()
	{
		return GetValue("BrightColor");
	}
	
	public static function GetDimColor()
	{
		return GetValue("DimColor");
	}
			
	// public static function GetWeatherApiKey()
	// {
	// 	var waKey = GetTmpValue("WeatherApiKey");
	// 	return waKey != null ? waKey : ""; 
	// }
	
	public static function GetExtraTimeZone()
	{
		return GetTmpValue(_etz);
	}
	
	public static function SetExtraTimeZone(etz)
	{
		SetTmpValue(_etz, etz);
	}
	
	public static function GetLastKnownLocation()
	{
		var location = GetTmpValue(_lastKnownLocation);
		return location;
	}
	
	public static function SetLastKnownLocation(lastKnownLocation)
	{
		SetTmpValue(_lastKnownLocation, lastKnownLocation);
	}
	
	public static function GetEtzId()
	{
		return GetValue("etzId");
	}
	
	public static function SetAppVersion(appVersionValue)
	{
		SetValue(_appVersion, appVersionValue); 
	}
	
	public static function GetAppVersion()
	{
		var appVersion = GetValue(_appVersion);
		return appVersion != null ? appVersion :"0.0"; 
	}
	
	public static function GetIsShowCity()
	{
		return GetValue("is-show-city");
	}
	
	public static function GetWindSystem()
	{
		return GetValue("windSystem");
	}
	
	public static function GetTempSystem()
	{
		return GetValue("tempSystem");
	}
	
	public static function GetDistSystem()
	{
		return GetValue("distSystem");
	}
	
	public static function GetAltimeterSystem()
	{
		return GetValue("altimeter-system");
	}
	
	public static function GetCityAlign()
	{
		return GetValue("city-align");
	}
	
	public static function GetAlarmAlign()
	{
		return GetValue("alarm-align");
	}
	
	public static function GetIsTest()
	{
		return Ui.loadResource(Rez.Strings.IsTest).toNumber() == 1;
	}
	
	public static function GetIsShowExchangeRate()
	{
		return GetTmpValue(_isShowExchangeRate);
	}
	
	public static function SetIsShowExchangeRate(isShowExchange)
	{
		SetTmpValue(_isShowExchangeRate, isShowExchange);
	}	
	
	public static function GetPulseField()
	{
		return GetTmpValue(_pulseField);
	}
	
	public static function SetPulseField(pulseField)
	{
		SetTmpValue(_pulseField, pulseField);
	}
	
	public static function GetBaseCurrency()
	{
		return GetTmpValue(_baseCurrency);
	}
	
	public static function GetTargetCurrency()
	{
		return GetTmpValue(_targetCurrency);
	}
	
	public static function SetBaseCurrency(baseCurrency)
	{
		SetTmpValue(_baseCurrency, baseCurrency);
	}
	public static function SetTargetCurrency(targetCurrency)
	{
		SetTmpValue(_targetCurrency, targetCurrency);
	}
	
	public static function GetBaseCurrencyId()
	{
		return GetValue("base-currency-id2");
	}
	
	public static function GetTargetCurrencyId()
	{
		return GetValue("target-currency-id2");
	}
	
	public static function GetIsShowWeather()
	{
		return GetValue("is-show-weather");
	}
	
	public static function GetIsShowSeconds()
	{
		return GetValue("is-show-seconds");
	}
	
	public static function SetExchangeRate(rate)
	{
		SetTmpValue(_exchangeRate, rate);
	}
	
	public static function GetExchangeRate()
	{
		return GetTmpValue(_exchangeRate);
	}
	
	public static function GetShowAlarm()
	{
		return GetValue("show-alarm");
	}
	
	public static function GetShowMessage()
	{
		return GetValue("show-message");
	}	
	
	public static function GetField(id)
	{
		return GetValue("field-" + id) as Toybox.Lang.Number;
	}

	public static function GetRefInterval()
	{
		return GetTmpValue("ref-interval");
	}

	public static function SetRefInterval(interval)
	{
		SetTmpValue("ref-interval", interval);
	}


	private static function GetValue(key)
	{
		var value = null;
		try
		{
			value = Properties.getValue(key);
		}
		finally 
		{
			return value;
		}
	}

	private static function SetValue(key, value)
	{
		try
		{
			Properties.setValue(key, value);
		}
		catch(ex) 
		{
			Sys.println("set value error (" + key + ", " + value + ") \n" + ex.getErrorMessage());
		}
	}

	private static function GetTmpValue(key)
	{
		return Storage.getValue(key);
	}

	private static function SetTmpValue(key, value)
	{
		Storage.setValue(key, value);
	}
	
}