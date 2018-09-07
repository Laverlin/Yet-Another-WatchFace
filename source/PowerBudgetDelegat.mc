using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

// Handle power budget events
//
class PowerBudgetDelegate extends Ui.WatchFaceDelegate
{
	function initialize()
	{
		WatchFaceDelegate.initialize();
	}
	
	function onPowerBudgetExceeded(powerInfo)
	{
		Sys.println("Average : " + powerInfo.executionTimeAverage);
		Sys.println("Allowed : " + powerInfo.executionTimeLimit);
	}
}