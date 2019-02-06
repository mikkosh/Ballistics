using Toybox.WatchUi as Ui;
using BallisticUnitConversions as BUC;


class SightSettingsView extends RowSettingsView 
{
	function initialize() {
		RowSettingsView.initialize();
	}

    //! Load your resources here
    function onLayout(dc) 
    {
    	setTitle("Sight & Cartridge");
    	onUpdate(dc);
    }

    //! Update the view
    function onUpdate(dc) {
    	clearRows();
    	
    	var bp = Application.getApp().getBProp();
    	var pf = new BUC.PropertyFormatter(bp);
 		
        addRow("Sight height", Lang.format("$1$$2$", [pf.getSightHeight(true), pf.getSightHeightUnit()]));
        addRow("Sight click", pf.getSightMoa(true));
 		addRow("Zero range", Lang.format("$1$$2$", [pf.getZeroRange(true), pf.getRangeUnit()]));
        
        addRow("Drag function", bp.getDragFunction());
        addRow("Drag coefficient", bp.getDragCoefficient().format("%2.3f"));
        addRow("Initial velocity", Lang.format("$1$$2$", [pf.getInitialVelocity(true), pf.getInitialVelocityUnit()]));
        addRow("Atm correction", Application.getApp().getProperty("UseAtmCorr") ? "on" : "off");
        RowSettingsView.onUpdate(dc);   
    }
}

class SightSettingsInputDelegate extends Ui.InputDelegate {
	var view;
	function initialize(pView) {
		view = pView;
		Ui.InputDelegate.initialize();
	}
 	// @param evt KEY_XXX enum value
    //! @return true if handled, false otherwise
    function onKey(evt) {
    	
    	if (evt.getKey() == Ui.KEY_ESC) {
			WatchUi.popView(Ui.SLIDE_DOWN);
    		return true;
		} else if(evt.getKey() == Ui.KEY_DOWN) {
			view.nextIndex();
			Ui.requestUpdate();
			return true;
		} else if(evt.getKey() == Ui.KEY_UP) {
			view.prevIndex();
			Ui.requestUpdate();
			return true;
		}
    	return false;
    }
    
    function onTap(evt) {
    	var coord = evt.getCoordinates();
    	var settings = System.getDeviceSettings();
    	if(coord[1] < settings.screenHeight/2) {
    		view.prevIndex();
			Ui.requestUpdate();
			return true;
    	} else {
    		view.nextIndex();
			Ui.requestUpdate();
			return true;
    	}
    	return false;
    }
   
}
