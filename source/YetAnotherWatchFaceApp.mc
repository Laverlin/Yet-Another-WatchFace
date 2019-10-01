using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Background as Background;
using Toybox.System as Sys;
using Toybox.Timer as Timer;
using Toybox.Lang as Lang;

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
    	_watchFaceView = new YetAnotherWatchFaceView(self);
    	
    	baseInitApp();
    	
    	InitBackgroundEvents();
    	
        return [ _watchFaceView, new PowerBudgetDelegate() ];
    }
    
    // New app settings have been received so trigger a UI update
    //
    function onSettingsChanged() 
    {
		baseInitApp();
	
    	InitBackgroundEvents();

    	_watchFaceView.InvalidateLayout();
    	
        Ui.requestUpdate();
    }
    
    function onBackgroundData(data) 
    {
    	//Sys.println("on bg data : " + data);
        if (data != null)
        {
        	if (data.hasKey("isErr"))
        	{
        		Setting.SetConError(true);	
        	}
        	else
        	{
        		Setting.SetConError(false);
        	}
        	
        	
        	if (data.hasKey("exchange"))
        	{
        		Setting.SetExchangeRate(data["exchange"]["ExchangeRate"]);
        	}
        	
        	if (data.hasKey("city"))
        	{
        		Setting.SetCity(data["city"]);
        	}
        	
        	if (data.hasKey("weather"))
        	{
        		Setting.SetWeather(data["weather"]);
        	}
        }

        Ui.requestUpdate();
    }    

    function getServiceDelegate()
    {
        return [new BackgroundServiceDelegate()];
    }
    
    function InitBackgroundEvents()
    {
    	Setting.SetConError(false);
    	//var time = System.getClockTime();
    	//Sys.println(Lang.format("callback happened $1$:$2$:$3$", [time.hour, time.min, time.sec]));
    	
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
		
		// need to erase current exchange rate, since it not actual anymore
		//
		if (!symbols["symbols"][Setting.GetBaseCurrencyId()].equals(Setting.GetBaseCurrency()) ||
			!symbols["symbols"][Setting.GetTargetCurrencyId()].equals(Setting.GetTargetCurrency()))
		{
       		Setting.SetExchangeRate(0);
		}
		
		// save new symbols in OS
		//
		Setting.SetBaseCurrency(symbols["symbols"][Setting.GetBaseCurrencyId()]);
		Setting.SetTargetCurrency(symbols["symbols"][Setting.GetTargetCurrencyId()]);		
		symbols = null; 
		
        // Find timezone DST data and save it in object store
    	//
		var tzData = null; 
		
		var tzIds = [Rez.JsonData.tzData1, Rez.JsonData.tzData2, Rez.JsonData.tzData3, Rez.JsonData.tzData4, Rez.JsonData.tzData5, Rez.JsonData.tzData6,
			Rez.JsonData.tzData7, Rez.JsonData.tzData8, Rez.JsonData.tzData9, Rez.JsonData.tzData10, Rez.JsonData.tzData11, Rez.JsonData.tzData12,
			Rez.JsonData.tzData13, Rez.JsonData.tzData14, Rez.JsonData.tzData15, Rez.JsonData.tzData16, Rez.JsonData.tzData17, Rez.JsonData.tzData18,
			Rez.JsonData.tzData19, Rez.JsonData.tzData20, Rez.JsonData.tzData21, Rez.JsonData.tzData22, Rez.JsonData.tzData23, Rez.JsonData.tzData24, 
			Rez.JsonData.tzData25, Rez.JsonData.tzData26, Rez.JsonData.tzData27, Rez.JsonData.tzData28, Rez.JsonData.tzData29, Rez.JsonData.tzData30,
			Rez.JsonData.tzData31, Rez.JsonData.tzData32, Rez.JsonData.tzData33, Rez.JsonData.tzData34, Rez.JsonData.tzData35, Rez.JsonData.tzData36,
			Rez.JsonData.tzData37, Rez.JsonData.tzData38, Rez.JsonData.tzData39, Rez.JsonData.tzData40];
		tzData = Ui.loadResource(tzIds[Setting.GetEtzId() - 1]);

		Setting.SetExtraTimeZone(tzData);
    
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