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

    // Return the initial view of your application here
    //
    function getInitialView() 
    {
    	baseInitApp();
    	InitBackgroundEvents();
    	
    	_watchFaceView = new YetAnotherWatchFaceView();
        return [ _watchFaceView, new PowerBudgetDelegate() ];
    }

    // New app settings have been received so trigger a UI update
    //
    function onSettingsChanged() 
    {
		baseInitApp();
	

    	InitBackgroundEvents();
    	
    	_watchFaceView.SetColors();
        Ui.requestUpdate();
    }
    
    function onBackgroundData(data) 
    {
    	Background.registerForTemporalEvent(new Toybox.Time.Duration(60 * 60));
        if (data != null)
        {
       		Setting.SetWeatherInfo(data);
       		Setting.SetExchangeRate(data["ExchangeRate"]);
        }

        Ui.requestUpdate();
    }    

    function getServiceDelegate()
    {
        return [new BackgroundServiceDelegate()];
    }
    
    function InitBackgroundEvents()
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
    }
    
    function baseInitApp()
    {
    
 	 	// load actual currency symbols and save it in object store
		//
		var symbols = Ui.loadResource(Rez.JsonData.currencySymbols);
		
		// save new symbols in OS
		//
		Setting.SetBaseCurrency(symbols["symbols"][Setting.GetBaseCurrencyId()]);
		Setting.SetTargetCurrency(symbols["symbols"][Setting.GetTargetCurrencyId()]);
		
		// need to erase current exchange rate, since it not actual anymore
		//
		if (!symbols["symbols"][Setting.GetBaseCurrencyId()].equals(Setting.GetBaseCurrency()) ||
			!symbols["symbols"][Setting.GetTargetCurrencyId()].equals(Setting.GetTargetCurrency()))
		{
			var weatherInfo = Setting.GetWeatherInfo();
        	if (weatherInfo != null)
        	{
        		Setting.SetExchangeRate(0);
        	}			
		}
		symbols = null; 
		   
        // Find timezone DST data and save it in object store
    	//
		var tzData = Ui.loadResource(Rez.JsonData.tzData);
        for (var i=0; i < tzData.size(); i++ )
        {
        	if (tzData[i]["Id"] == Setting.GetEtzId())
        	{
        		Setting.SetExtraTimeZone(tzData[i]);
        		break;
        	}
        }
		tzData = null;
    
    	// Set base configuraton for displayed fiels
 	    //
 	    Setting.SetPulseField(0);
 	    Setting.SetIsShowExchangeRate(false);
    	for (var i = 3; i < 6; i++)
		{
			if (Setting.GetField(i) == 3)
			{
				Setting.SetPulseField(i);
			}
			
			if (Setting.GetField(i) == 1)
			{
				Setting.SetIsShowExchangeRate(true);
			}
		}
    }
    
    
}