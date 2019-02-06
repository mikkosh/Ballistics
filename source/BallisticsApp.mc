using Toybox.Application as App;
using BallisticUnitConversions as BUC;

class BallisticsApp extends App.AppBase {
	
	const PROPKEY_BALL = "b12";
	var bProperties = null;
	
	function initialize() {
		App.AppBase.initialize();
	}
	
    //! onStart() is called on application start up
    function onStart(state) {
    	bProperties = new BallisticsProperties((state != null) ? state[PROPKEY_BALL] : getProperty(PROPKEY_BALL));
    }

    //! onStop() is called when application is exiting
    function onStop(state) {
    	var propState = bProperties.getState();
    	if(state != null) {
    		state[PROPKEY_BALL] = propState;
    	}
    	setProperty(PROPKEY_BALL, propState);
    }
    
    function onSettingsChanged() {
    	App.AppBase.onSettingsChanged();
    }
    
	
    function getInitialView() {
        return [ new BallisticsView(), new BallisticsInputDelegate() ];
    }
    
    function getBProp() {
    	return bProperties;
	}
	
	function resetState() {
		clearProperties();
		bProperties = new BallisticsProperties(null);
	}
}