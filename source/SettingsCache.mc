class SettingsCache
{
	function initialize() 
	{
		field3 = Setting.GetField(3);
		field4 = Setting.GetField(4);
		field5 = Setting.GetField(5);
		connError = Setting.GetConError();
		weather = Setting.GetWeather();
		lastKnownLocation = Setting.GetLastKnownLocation();
		weatherProvider = Setting.GetWeatherProvider();
		weatherApiKey = Setting.GetWeatherApiKey();
		weatherTempSystem = Setting.GetTempSystem();
		weatherWindSystem = Setting.GetWindSystem();
		extraTimeZone = Setting.GetExtraTimeZone();
		exchangeRate = Setting.GetExchangeRate();
		targetCurrency = Setting.GetTargetCurrency();
		distanceSystem = Setting.GetDistSystem();
		altimeterSystem = Setting.GetAltimeterSystem();
		showMessage = Setting.GetShowMessage();
		showAlarm = Setting.GetShowAlarm();
		city = Setting.GetCity();
		dateOrder = Setting.GetDateOrder();
		isShowMoon = Setting.GetShowMoon();

		isShowSeconds = Setting.GetIsShowSeconds();
		pulseField = Setting.GetPulseField();
		timeColor = Setting.GetTimeColor();
		brightColor = Setting.GetBrightColor();
		backgroundColor = Setting.GetBackgroundColor();
	}
	public var field3;
	public var field4;
	public var field5;
	public var connError;
	public var weather;
	public var lastKnownLocation;
	public var weatherProvider;
	public var weatherApiKey;
	public var weatherTempSystem;
	public var weatherWindSystem;
	public var extraTimeZone;
	public var exchangeRate;
	public var targetCurrency;
	public var distanceSystem;
	public var altimeterSystem;
	public var showMessage;
	public var showAlarm;
	public var city;
	public var dateOrder;
	public var isShowMoon;
	public var isShowSeconds;
	public var pulseField;
	public var timeColor;
	public var brightColor;
	public var backgroundColor;	
}