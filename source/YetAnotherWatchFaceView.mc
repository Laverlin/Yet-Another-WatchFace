using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.Time as Time;
using Toybox.Weather as Weather;


// Main WatchFace view
//
class YetAnotherWatchFaceView extends Ui.WatchFace 
{
	hidden var _layouts = {};
	hidden var _blayout = {};
	hidden var _fonts = [
		Ui.loadResource(Rez.Fonts.hint),
		Ui.loadResource(Rez.Fonts.icon_font), 
		Ui.loadResource(Rez.Fonts.vertical_font),
		Rez.Fonts has :digits ? Ui.loadResource(Rez.Fonts.digits) : null,
		Rez.Fonts has :text ? Ui.loadResource(Rez.Fonts.text) : null
		];
	hidden var _funcs = [
		:DisplayLocation, :DisplayBottomAlarmCount, :DisplayBottomMessageCount, 
		:DisplayDate, :DisplayTime, :DisplayPmAm, :DisplaySeconds,
		:DisplayTemp, :DisplayWind, :DisplayConnection, 
		:LoadField3, :LoadField4, :LoadField5, 
		:DisplayWatchStatus, :DisplayBottomLine];

	hidden var _secDim;
	hidden var _displayFunctions = new DisplayFunctions();
	hidden var _colors;
	hidden var _wfApp;
	hidden var _lastBg = null;
	hidden var _bgInterval = new Toybox.Time.Duration(59 * 60); //one hour
	hidden var _upTop = true;

	hidden var _isCanBurn = false;
	hidden var _isInLowPower = false;
	hidden var _checkmateImage = null;

	hidden var _settingCache = new SettingsCache();
	
    function initialize(wfApp) 
    {
        WatchFace.initialize();
        _wfApp = wfApp;

		Setting.SetAppVersion(Ui.loadResource(Rez.Strings.AppVersionValue));
		Setting.SetWatchServerToken(Ui.loadResource(Rez.Strings.WatchServerTokenValue));
		Setting.SetDeviceName(Ui.loadResource(Rez.Strings.DeviceName));

		var deviceSettings = Sys.getDeviceSettings();
        if(deviceSettings has :requiresBurnInProtection) {    
            _isCanBurn = deviceSettings.requiresBurnInProtection;
			_checkmateImage = Application.loadResource( Rez.Drawables.checkmate ) as Ui.BitmapResource;
        }
		
    }

	function InvalidateSettingCache() {
		_settingCache = new SettingsCache();
	}

	// This method is called when the device re-enters sleep mode.
	//
    function onEnterSleep() {
        _isInLowPower = true;
        Ui.requestUpdate(); 
    }
    
    // This method is called when the device exits sleep mode.
	//
    function onExitSleep() {
        _isInLowPower = false;
        Ui.requestUpdate(); 
    }

    // Load your resources here
    //
    function onLayout(dc) 
    {
    	_secDim = [dc.getTextWidthInPixels("00", Gfx.FONT_TINY), dc.getFontHeight(Gfx.FONT_TINY)];
		
		InvalidateLayout();
    }
    
    // calls every second for partial update
    //
    function onPartialUpdate(dc)
    {
		if (_isInLowPower && _isCanBurn) 
		{
			return;
		}

    	if (_settingCache.isShowSeconds)
    	{
	    	dc.setClip(_layouts["sec"]["x"][0] - _secDim[0], _layouts["sec"]["y"][0], _layouts["sec"]["x"][0] + 1, _secDim[1]);
	    	dc.setColor(_settingCache.timeColor, _settingCache.backgroundColor);
	    	dc.drawText(
	    		_layouts["sec"]["x"][0], 
	    		_layouts["sec"]["y"][0], 
	    		Gfx.FONT_TINY, 
	    		Sys.getClockTime().sec.format("%02d"), 
	    		Gfx.TEXT_JUSTIFY_RIGHT);
		}
		
		if (_settingCache.pulseField != 0)
		{
			var layout = _layouts["field" + _settingCache.pulseField];
			var pulseData = _displayFunctions.DisplayPulse(layout);
			
			if (pulseData[2])
			{
				dc.setClip(layout["x"][0], layout["y"][0], layout["x"][0] + _secDim[0], _secDim[1]);
				dc.setColor(_settingCache.brightColor, _settingCache.backgroundColor);
				dc.drawText(layout["x"][0], layout["y"][0], Gfx.FONT_TINY, pulseData[0], Gfx.TEXT_JUSTIFY_LEFT);
			}
		}
    }
    
    // Update the view
    //
    function onUpdate(dc)  
    {
   		_displayFunctions.setTime(Time.now());
   		_displayFunctions.setDc(dc, _fonts);
		_displayFunctions.setSettings(_settingCache);
   		
		var location = getGpsPosition();
		if (location == null) {
			location = getWeatherPosition();
		}
		if (location != null) {
			Setting.SetLastKnownLocation(location);
		}


		/// fire background process if needed
		///
		if (Setting.GetRefInterval() != null) 
		{
			_bgInterval = new Toybox.Time.Duration(59 * Setting.GetRefInterval().toNumber());
		}
		if (_lastBg == null)
		{
			_lastBg = new Time.Moment(Time.now().value());
			_wfApp.InitBackgroundEvents();
		}
		else if (_lastBg.add(_bgInterval).lessThan(new Time.Moment(Time.now().value())))
		{
			_lastBg = new Time.Moment(Time.now().value());
			_wfApp.InitBackgroundEvents();
		}
		
		dc.clearClip();
		dc.setColor(Gfx.COLOR_TRANSPARENT, Setting.GetBackgroundColor());
    	dc.clear();

		var layout = (_isInLowPower && _isCanBurn) ? _blayout : _layouts;
    	
		for (var i = 0; i < layout.size(); i++)
		{
			var funcs = null;
			if (_displayFunctions has _funcs[layout.values()[i]["fun"]])
			{
				funcs = _displayFunctions.method(_funcs[layout.values()[i]["fun"]]).invoke(layout.values()[i]);
			}
			else
			{
				funcs = ["", "", "", "", ""];
			}
				
			var x = null as Lang.Number;
			var f = null as Toybox.Graphics.FontReference;	
			var text = null as Lang.String;
			
			for(var j = 0; j < layout.values()[i]["x"].size(); j++)
			{
				dc.setColor(_colors[layout.values()[i]["c"][j]], 
					layout.values()[i].hasKey("tb") ? Gfx.COLOR_TRANSPARENT : Setting.GetBackgroundColor());

	        	var a = layout.values()[i]["a"][j];
	        	
	        	// if lcor is present AND lenght of prev text is greater than default X. 
	        	// then default x should be increased on lcor
	        	//
	        	if (layout.values()[i].hasKey("lcor") && 
	        		layout.values()[i]["lcor"] != null &&
	        		text != null &&
	        		x + dc.getTextWidthInPixels(text, f) > layout.values()[i]["x"][j])
	        	{
	        		x = x + dc.getTextWidthInPixels(text, f) + layout.values()[i]["lcor"];
	        	}
	        	else
	        	{
		        	// if cor is present default X should be adjasted on cor
		        	//
		        	if (layout.values()[i].hasKey("cor") && 
		        		layout.values()[i]["cor"][j] != null &&
		        		text != null) 
		        	{
		        		x = x + (a == 0 ? -1 : 1) * dc.getTextWidthInPixels(text, f) + layout.values()[i]["cor"][j];
		        	}
		        	else
		        	{
		        		x = layout.values()[i]["x"][j];
		        	}
	        	}

				f = layout.values()[i]["f"][j] < 100 
	        			? layout.values()[i]["f"][j] 
	        			: _fonts[layout.values()[i]["f"][j] - 100];

				text = (!layout.values()[i].hasKey("t") || layout.values()[i]["t"][j] == null)
					? funcs[j] 
	        		: layout.values()[i]["t"][j];
	        			
				dc.drawText(x, layout.values()[i]["y"][j], f, text, a);
			}
		}
		
		dc.setColor(Setting.GetTimeColor(), Gfx.COLOR_TRANSPARENT);
		var line = Ui.loadResource(Rez.JsonData.l_line);
        dc.drawLine(line["x"][0], line["y"][0], line["x"][1], line["y"][1]);
        
        if (Setting.GetIsTest())
		{
			dc.setColor(Setting.GetDimColor(), Gfx.COLOR_TRANSPARENT);
			dc.drawText(dc.getWidth()/2, dc.getHeight() - 30, _fonts[0], Setting.GetAppVersion(), Gfx.TEXT_JUSTIFY_CENTER);
		}

		// draw checkmate
		//
		if(_isInLowPower && _isCanBurn) {
			_upTop=!_upTop;
			dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
          	for (var row=(_upTop) ? 1 : 0; row < dc.getHeight(); row += 50) {
            	for (var col=0 ; col <= dc.getWidth(); col += 50) {
					dc.drawBitmap(row, col, _checkmateImage);
                }
            }
		}
    }

    function InvalidateLayout()
    {
		InvalidateSettingCache();
    	_colors = [Setting.GetTimeColor(), Setting.GetBrightColor(), Setting.GetDimColor(), 0xFF422D];
    	
    	_layouts = {};
		_blayout = {};    	 	
    	
		_layouts.put("hour", Ui.loadResource(Rez.JsonData.l_time));
		_blayout.put("hour", Ui.loadResource(Rez.JsonData.l_time));
    	_layouts.put("date", Ui.loadResource(Rez.JsonData.l_date));
		_blayout.put("date", Ui.loadResource(Rez.JsonData.l_date));  

		_layouts.put("btooth", Ui.loadResource(Rez.JsonData.l_bt));  	
    	
    	if (Setting.GetIsShowSeconds())
    	{
    		_layouts.put("sec", Ui.loadResource(Rez.JsonData.l_sec));
    	}
    	
    	if (!Sys.getDeviceSettings().is24Hour)
    	{
    		_layouts.put("pmam", Ui.loadResource(Rez.JsonData.l_pmam));
    	}
    	
    	if (Setting.GetIsShowWeather())
    	{
    		_layouts.put("temp", Ui.loadResource(Rez.JsonData.l_temp));
			_blayout.put("temp", Ui.loadResource(Rez.JsonData.l_temp));
    		_layouts.put("wind", Ui.loadResource(Rez.JsonData.l_wind));
			_blayout.put("wind", Ui.loadResource(Rez.JsonData.l_wind));
    	}
    	
    	
    	if (Setting.GetIsShowCity())
    	{
    		_layouts.put("city", Ui.loadResource(Setting.GetCityAlign() == 0 ? Rez.JsonData.l_city_left : Rez.JsonData.l_city_center));
    	}  
    	
    	_layouts.put("field3", Ui.loadResource(Rez.JsonData.l_field3));
		_blayout.put("field3", Ui.loadResource(Rez.JsonData.l_field3));

    	_layouts.put("field4", Ui.loadResource(Rez.JsonData.l_field4));
		_blayout.put("field4", Ui.loadResource(Rez.JsonData.l_field4));

    	_layouts.put("field5", Ui.loadResource(Rez.JsonData.l_field5));
		_blayout.put("field5", Ui.loadResource(Rez.JsonData.l_field5));

    	_layouts.put("battery", Ui.loadResource(Rez.JsonData.l_battery));
    	
 		_layouts.put("bottom-line", Ui.loadResource(
 			(Setting.GetBottomLayout() == 0) ? Rez.JsonData.l_bottom_line1 : Rez.JsonData.l_bottom_line2));
 		
    	
    	_displayFunctions = new DisplayFunctions();
     }



	private function getGpsPosition() 
	{
		var locationInfo = Position.getInfo();
		if (locationInfo == null || locationInfo.position == null) {
			return null;
		}
		var location = locationInfo.position.toDegrees();
		if ((Math.round(location[0]) == 0 && Math.round(location[1]) == 0) ||
			Math.round(location[0]) == 180 && Math.round(location[1]) == 180) {
			return null;
		}
		return location;
	}

	private function getWeatherPosition()
	{
		var conditions = Weather.getCurrentConditions();
		if (conditions == null || conditions.observationLocationPosition == null) {
			return null;
		}
		var location = conditions.observationLocationPosition.toDegrees();
		if ((Math.round(location[0]) == 0 && Math.round(location[1]) == 0) ||
			Math.round(location[0]) == 180 && Math.round(location[1]) == 180) {
			return null;
		}
		return location;
	}
}
