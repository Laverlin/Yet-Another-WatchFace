using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.Time as Time;


// Main WatchFaace view
// ToDo:: 
//        -- 1. Create Wrapper around ObjectStore 
//        -- 2. Move UI logic to functions
//        -- 3. Fix Timezone Issue 
//		  -- 4. Add option to show city name
//		  -- 5. Adjust exchange rate output
//        6. Refactor backround process (error handling)
//        -- 7. Option to Show weather
//        8. Refactor resources, name conventions, etc..
//
class YetAnotherWatchFaceView extends Ui.WatchFace 
{
	hidden var _layouts = {};
	hidden var _fonts = [
		Ui.loadResource(Rez.Fonts.unicode_mss16_font), Ui.loadResource(Rez.Fonts.icon_font), Ui.loadResource(Rez.Fonts.vertical_font)];
	hidden var _funcs = [
		:DisplayLocation, :DisplayBottomAlarmCount, :DisplayBottomMessageCount, 
		:DisplayDate, :DisplayTime, :DisplayPmAm, :DisplaySeconds,
		:DisplayTemp, :DisplayWind, :DisplayConnection, 
		:LoadField3, :LoadField4, :LoadField5, 
		:DisplayWatchStatus, :DisplayBottomLine];

	hidden var _secDim;
	hidden var _is90 = false;
	hidden var _displayFunctions = new DisplayFunctions();
	hidden var _colors;
	hidden var _wfApp;
	hidden var _lastBg = null;
	hidden var _bgInterval = new Toybox.Time.Duration(59 * 60); //one hour
	
    function initialize(wfApp) 
    {
        WatchFace.initialize();
        _wfApp = wfApp;

		Setting.SetAppVersion(Ui.loadResource(Rez.Strings.AppVersionValue));
		Setting.SetWatchServerToken(Ui.loadResource(Rez.Strings.WatchServerTokenValue));
		Setting.SetExchangeApiKey(Ui.loadResource(Rez.Strings.ExchangeApiKeyValue));
		Setting.SetIsTest(Ui.loadResource(Rez.Strings.IsTest).toNumber() == 1);
		Setting.SetDeviceName(Ui.loadResource(Rez.Strings.DeviceName));
		
    }

    // Load your resources here
    //
    function onLayout(dc) 
    {
    	_secDim = [dc.getTextWidthInPixels("00", Gfx.FONT_TINY), dc.getFontHeight(Gfx.FONT_TINY)];
    	_is90 = (dc.getFontHeight(Gfx.FONT_NUMBER_HOT) == 90 || 
    		dc.getFontHeight(Gfx.FONT_NUMBER_HOT) == 82 ||
    		dc.getFontHeight(Gfx.FONT_NUMBER_HOT) == 92) ? true : false;
    	//Sys.println(dc.getFontHeight(Gfx.FONT_NUMBER_HOT));

		InvalidateLayout();
    }
    
    // calls every second for partial update
    //
    function onPartialUpdate(dc)
    {
    	if (Setting.GetIsShowSeconds())
    	{
	    	dc.setClip(_layouts["sec"]["x"][0] - _secDim[0], _layouts["sec"]["y"][0], _layouts["sec"]["x"][0] + 1, _secDim[1]);
	    	dc.setColor(Setting.GetTimeColor(), Setting.GetBackgroundColor());
	    	dc.drawText(
	    		_layouts["sec"]["x"][0], 
	    		_layouts["sec"]["y"][0], 
	    		Gfx.FONT_TINY, 
	    		Sys.getClockTime().sec.format("%02d"), 
	    		Gfx.TEXT_JUSTIFY_RIGHT);
		}
		
		if (Setting.GetPulseField() != 0)
		{
			var layout = _layouts["field" + Setting.GetPulseField()];
			var pulseData = _displayFunctions.DisplayPulse(layout);
			
			if (pulseData[2])
			{
				dc.setClip(layout["x"][0], layout["y"][0], layout["x"][0] + _secDim[0], _secDim[1]);
				dc.setColor(Setting.GetBrightColor(), Setting.GetBackgroundColor());
				dc.drawText(layout["x"][0], layout["y"][0], Gfx.FONT_TINY, pulseData[0], Gfx.TEXT_JUSTIFY_LEFT);
			}
		}
    }
    
    // Update the view
    //
    function onUpdate(dc)  
    {
   		_displayFunctions.setTime(Gregorian.info(Time.now(), Time.FORMAT_MEDIUM));
   		_displayFunctions.setDc(dc, _fonts);
   		_displayFunctions.setSettings(new SettingsCache());
   		
    	var info = Activity.getActivityInfo();
    	
    	// starting from 3.1.7 empty location returns 0
    	//
    	//Sys.println(info.currentLocation + ", " + Lang.format("$1$.$2$.$3$", Sys.getDeviceSettings().monkeyVersion));
    	if (info != null && info.currentLocation != null)
    	{
    		var location = info.currentLocation.toDegrees();
    		if (location[0] != 0.0 && location[1] != 0.0)
    		{
    			//Sys.println(location[0] + ", " + location[1]);
    			Setting.SetLastKnownLocation(location);
    		}
    	} 

		/// fire background process if needed
		///
		if (_lastBg == null)
		{
			_lastBg = new Time.Moment(Time.now().value());
		}
		else if (_lastBg.add(_bgInterval).lessThan(new Time.Moment(Time.now().value())))
		{
			_lastBg = new Time.Moment(Time.now().value());
			_wfApp.InitBackgroundEvents();
		}
		
		dc.clearClip();
		dc.setColor(Gfx.COLOR_TRANSPARENT, Setting.GetBackgroundColor());
    	dc.clear();
    	
		for (var i = 0; i < _layouts.size(); i++)
		{
			var funcs = null;
			if (_displayFunctions has _funcs[_layouts.values()[i]["fun"]])
			{
				funcs = _displayFunctions.method(_funcs[_layouts.values()[i]["fun"]]).invoke(_layouts.values()[i]);
			}
			else
			{
				funcs = ["", "", "", "", ""];
			}
				
			var x = null;
			var f = null;	
			var text = null;
			
			for(var j = 0; j < _layouts.values()[i]["x"].size(); j++)
			{
				dc.setColor(_colors[_layouts.values()[i]["c"][j]], 
					_layouts.values()[i].hasKey("tb") ? Gfx.COLOR_TRANSPARENT : Setting.GetBackgroundColor());

	        	var a = _layouts.values()[i]["a"][j];
	        	
	        	// if lcor is present AND lenght of prev text is greater than default X. 
	        	// then default x should be increased on lcor
	        	//
	        	if (_layouts.values()[i].hasKey("lcor") && 
	        		_layouts.values()[i]["lcor"] != null &&
	        		text != null &&
	        		x + dc.getTextWidthInPixels(text, f) > _layouts.values()[i]["x"][j])
	        	{
	        		x = x + dc.getTextWidthInPixels(text, f) + _layouts.values()[i]["lcor"];
	        	}
	        	else
	        	{
		        	// if cor is present default X should be adjasted on cor
		        	//
		        	if (_layouts.values()[i].hasKey("cor") && 
		        		_layouts.values()[i]["cor"][j] != null &&
		        		text != null) 
		        	{
		        		x = x + (a == 0 ? -1 : 1) * dc.getTextWidthInPixels(text, f) + _layouts.values()[i]["cor"][j];
		        	}
		        	else
		        	{
		        		x = _layouts.values()[i]["x"][j];
		        	}
	        	}

				f = _layouts.values()[i]["f"][j] < 100 
	        			? _layouts.values()[i]["f"][j] 
	        			: _fonts[_layouts.values()[i]["f"][j] - 100];

				text = (!_layouts.values()[i].hasKey("t") || _layouts.values()[i]["t"][j] == null)
					? funcs[j] 
	        		: _layouts.values()[i]["t"][j];
	        			
				dc.drawText(x, _layouts.values()[i]["y"][j], f, text, a);
			}
		}
		
		dc.setColor(Setting.GetTimeColor(), Gfx.COLOR_TRANSPARENT);
		var line = Ui.loadResource(Rez.JsonData.l_line);
        dc.drawLine(line["x"][0], line["y"][0], line["x"][1], line["y"][1]);
        
        if (Setting.GetIsTest())
		{
			dc.setColor(Setting.GetDimColor(), Gfx.COLOR_TRANSPARENT);
			dc.drawText(dc.getWidth()/2, dc.getHeight() - 20, _fonts[0], Setting.GetAppVersion(), Gfx.TEXT_JUSTIFY_CENTER);
		}
    }
    
    function InvalidateLayout()
    {
    	_colors = [Setting.GetTimeColor(), Setting.GetBrightColor(), Setting.GetDimColor(), 0xFF422D];
    	
    	_layouts = {};    	 	
    	
		_layouts.put("hour", Ui.loadResource(_is90 ? Rez.JsonData.l_time_f90 : Rez.JsonData.l_time));
    	_layouts.put("date", Ui.loadResource(_is90 ? Rez.JsonData.l_date_f90 : Rez.JsonData.l_date));
		_layouts.put("btooth", Ui.loadResource(Rez.JsonData.l_bt));    	
    	
    	if (Setting.GetIsShowSeconds())
    	{
    		_layouts.put("sec", Ui.loadResource(Rez.JsonData.l_sec));
    	}
    	
    	if (!Sys.getDeviceSettings().is24Hour)
    	{
    		_layouts.put("pmam", Ui.loadResource(_is90 ? Rez.JsonData.l_pmam_f90 : Rez.JsonData.l_pmam));
    	}
    	
    	if (Setting.GetIsShowWeather())
    	{
    		_layouts.put("temp", Ui.loadResource(Rez.JsonData.l_temp));
    		_layouts.put("wind", Ui.loadResource(Rez.JsonData.l_wind));
    	}
    	
    	
    	if (Setting.GetIsShowCity())
    	{
    		_layouts.put("city", Ui.loadResource(Setting.GetCityAlign() == 0 ? Rez.JsonData.l_city_left : Rez.JsonData.l_city_center));
    	}  
    	
    	_layouts.put("field3", Ui.loadResource(Rez.JsonData.l_field3));
    	_layouts.put("field4", Ui.loadResource(Rez.JsonData.l_field4));
    	_layouts.put("field5", Ui.loadResource(Rez.JsonData.l_field5));
    	_layouts.put("battery", Ui.loadResource(Rez.JsonData.l_battery));
    	
 		_layouts.put("bottom-line", Ui.loadResource(
 			(Setting.GetBottomLayout() == 0) ? Rez.JsonData.l_bottom_line1 : Rez.JsonData.l_bottom_line2));
 		
    	
    	_displayFunctions = new DisplayFunctions();
     }
}
