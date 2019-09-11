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

    	_watchFaceView.DropLayouts();
    	
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
		
		// save new symbols in OS
		//
		Setting.SetBaseCurrency(symbols["symbols"][Setting.GetBaseCurrencyId()]);
		Setting.SetTargetCurrency(symbols["symbols"][Setting.GetTargetCurrencyId()]);		
		symbols = null; 
		
        // Find timezone DST data and save it in object store
    	//
		var tzData = null; 
		
		if (Setting.GetEtzId() == 1) {tzData = Ui.loadResource(Rez.JsonData.tzData1);}
		else if (Setting.GetEtzId() == 2) {tzData = Ui.loadResource(Rez.JsonData.tzData2);}
		else if (Setting.GetEtzId() == 3) {tzData = Ui.loadResource(Rez.JsonData.tzData3);}
		else if (Setting.GetEtzId() == 4) {tzData = Ui.loadResource(Rez.JsonData.tzData4);}
		else if (Setting.GetEtzId() == 5) {tzData = Ui.loadResource(Rez.JsonData.tzData5);}
		else if (Setting.GetEtzId() == 6) {tzData = Ui.loadResource(Rez.JsonData.tzData6);}
		else if (Setting.GetEtzId() == 7) {tzData = Ui.loadResource(Rez.JsonData.tzData7);}
		else if (Setting.GetEtzId() == 8) {tzData = Ui.loadResource(Rez.JsonData.tzData8);}
		else if (Setting.GetEtzId() == 9) {tzData = Ui.loadResource(Rez.JsonData.tzData9);}
		else if (Setting.GetEtzId() == 10) {tzData = Ui.loadResource(Rez.JsonData.tzData10);}
		else if (Setting.GetEtzId() == 11) {tzData = Ui.loadResource(Rez.JsonData.tzData11);}
		else if (Setting.GetEtzId() == 12) {tzData = Ui.loadResource(Rez.JsonData.tzData12);}
		else if (Setting.GetEtzId() == 13) {tzData = Ui.loadResource(Rez.JsonData.tzData13);}
		else if (Setting.GetEtzId() == 14) {tzData = Ui.loadResource(Rez.JsonData.tzData14);}
		else if (Setting.GetEtzId() == 15) {tzData = Ui.loadResource(Rez.JsonData.tzData15);}
		else if (Setting.GetEtzId() == 16) {tzData = Ui.loadResource(Rez.JsonData.tzData16);}
		else if (Setting.GetEtzId() == 17) {tzData = Ui.loadResource(Rez.JsonData.tzData17);}
		else if (Setting.GetEtzId() == 18) {tzData = Ui.loadResource(Rez.JsonData.tzData18);}
		else if (Setting.GetEtzId() == 19) {tzData = Ui.loadResource(Rez.JsonData.tzData19);}
		else if (Setting.GetEtzId() == 20) {tzData = Ui.loadResource(Rez.JsonData.tzData20);}
		else if (Setting.GetEtzId() == 21) {tzData = Ui.loadResource(Rez.JsonData.tzData21);}
		else if (Setting.GetEtzId() == 22) {tzData = Ui.loadResource(Rez.JsonData.tzData22);}
		else if (Setting.GetEtzId() == 23) {tzData = Ui.loadResource(Rez.JsonData.tzData23);}
		else if (Setting.GetEtzId() == 24) {tzData = Ui.loadResource(Rez.JsonData.tzData24);}
		else if (Setting.GetEtzId() == 25) {tzData = Ui.loadResource(Rez.JsonData.tzData25);}
		else if (Setting.GetEtzId() == 26) {tzData = Ui.loadResource(Rez.JsonData.tzData26);}
		else if (Setting.GetEtzId() == 27) {tzData = Ui.loadResource(Rez.JsonData.tzData27);}
		else if (Setting.GetEtzId() == 28) {tzData = Ui.loadResource(Rez.JsonData.tzData28);}
		else if (Setting.GetEtzId() == 29) {tzData = Ui.loadResource(Rez.JsonData.tzData29);}
		else if (Setting.GetEtzId() == 30) {tzData = Ui.loadResource(Rez.JsonData.tzData30);}
		else if (Setting.GetEtzId() == 31) {tzData = Ui.loadResource(Rez.JsonData.tzData31);}
		else if (Setting.GetEtzId() == 32) {tzData = Ui.loadResource(Rez.JsonData.tzData32);}
		else if (Setting.GetEtzId() == 33) {tzData = Ui.loadResource(Rez.JsonData.tzData33);}
		else if (Setting.GetEtzId() == 34) {tzData = Ui.loadResource(Rez.JsonData.tzData34);}
		else if (Setting.GetEtzId() == 35) {tzData = Ui.loadResource(Rez.JsonData.tzData35);}
		else if (Setting.GetEtzId() == 36) {tzData = Ui.loadResource(Rez.JsonData.tzData36);}
		else if (Setting.GetEtzId() == 37) {tzData = Ui.loadResource(Rez.JsonData.tzData37);}
		else if (Setting.GetEtzId() == 38) {tzData = Ui.loadResource(Rez.JsonData.tzData38);}
		else if (Setting.GetEtzId() == 39) {tzData = Ui.loadResource(Rez.JsonData.tzData39);}
		else if (Setting.GetEtzId() == 40) {tzData = Ui.loadResource(Rez.JsonData.tzData40);}
		
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