using Toybox.Application as App;
using Toybox.WatchUi as Ui;

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
    function getInitialView() {
    	_watchFaceView = new YetAnotherWatchFaceView();
        return [ _watchFaceView ];
    }

    // New app settings have been received so trigger a UI update
    //
    function onSettingsChanged() {
    	_watchFaceView.UpdateSetting();
        Ui.requestUpdate();
    }

}