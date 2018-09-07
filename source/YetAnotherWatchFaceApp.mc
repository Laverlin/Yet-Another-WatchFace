using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Background as Background;
using Toybox.System as Sys;

(:background)
class YetAnotherWatchFaceApp extends App.AppBase {

	hidden var _watchFaceView; 
	
    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    //
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    //
    function onStop(state) {
    }

    // Return the initial view of your application here
    //
    function getInitialView() 
    {
    	Background.registerForTemporalEvent(new Time.Duration(60 * 60));
    	_watchFaceView = new YetAnotherWatchFaceView();
        return [ _watchFaceView, new PowerBudgetDelegate() ];
    }

    // New app settings have been received so trigger a UI update
    //
    function onSettingsChanged() {
    	_watchFaceView.UpdateSetting();
        Ui.requestUpdate();
    }
    
    function onBackgroundData(data) 
    {
        Sys.println(data);
        var weatherInfo = new WeatherInfo();
        if (data != null)
        {
        	weatherInfo.FromDictionary(data);
        	if (weatherInfo.Status == 1)
        	{
        		setProperty("WeatherInfo", data);
        	}
        }
        _watchFaceView.UpdateWeatherInfo(weatherInfo);
        Ui.requestUpdate();
    }    

    function getServiceDelegate()
    {
        return [new BackgroundServiceDelegate()];
    }
}