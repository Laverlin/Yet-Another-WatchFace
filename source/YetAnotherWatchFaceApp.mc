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
 		var FIVE_MINUTES = new Toybox.Time.Duration(5 * 60);
		var lastTime = Background.getLastTemporalEventTime();
		if (lastTime != null) 
		{
    		var nextTime = lastTime.add(FIVE_MINUTES);
    		Background.registerForTemporalEvent(nextTime);
		} 
		else 
		{
    		Background.registerForTemporalEvent(Time.now());
		}   	
    	
    	_watchFaceView = new YetAnotherWatchFaceView();
        return [ _watchFaceView, new PowerBudgetDelegate() ];
    }

    // New app settings have been received so trigger a UI update
    //
    function onSettingsChanged() 
    {
    	_watchFaceView.UpdateSetting();
        Ui.requestUpdate();
    }
    
    function onBackgroundData(data) 
    {
    	Background.registerForTemporalEvent(new Toybox.Time.Duration(60 * 60));
  
        if (data != null)
        {
        	var weatherInfo = WeatherInfo.FromDictionary(data);
        	
        	if (weatherInfo.WeatherStatus == 1 || weatherInfo.CityStatus == 1)
        	{
        		Setting.SetWeatherInfo(data);
        	}
        }

        Ui.requestUpdate();
    }    

    function getServiceDelegate()
    {
        return [new BackgroundServiceDelegate()];
    }
}