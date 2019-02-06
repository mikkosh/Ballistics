using Toybox.WatchUi as Ui;
using BallisticUnitConversions as BUC;
using Toybox.Graphics as Gfx;

class BallisticsView extends Ui.View 
{
	function initialize() {
		Ui.View.initialize();
	}
	//! Load your resources here
    function onLayout(dc) 
    {
    	setLayout(Rez.Layouts.MainLayout(dc));	
    	
    }
    
    //! Update the view
    function onUpdate(dc) 
    {
    	var bp = Application.getApp().getBProp();
    	var pf = new BUC.PropertyFormatter(bp);
 
 		View.findDrawableById("id_range").setText(pf.getTargetRange(true));
    	View.findDrawableById("id_range_unit").setText(pf.getRangeUnit());
      	View.findDrawableById("id_deg").setText(Lang.format("$1$$2$", [pf.getShootingAngle(), pf.getShootingAngleUnit()]));
      	View.findDrawableById("id_windspd").setText(Lang.format("$1$$2$", [pf.getWindSpeed(true), pf.getWindSpeedUnit()]));
      	
		View.onUpdate(dc);
		var p = View.findDrawableById("winddir_indicator");
		var vv = new DirectionArrow({:angle=>bp.getWindAngle()});
		vv.setLocation(p.locX, p.locY);
		vv.setSize(20, 20);
		vv.draw(dc);
		
    	return true;
    }
   
}

class BallisticsInputDelegate extends Ui.InputDelegate 
{

	function initialize() {
		Ui.InputDelegate.initialize();
	}
 	// @param evt KEY_XXX enum value
    //! @return true if handled, false otherwise
    function onKey(evt) 
    {	
    	if (evt.getKey() == Ui.KEY_MENU || evt.getKey() == Ui.KEY_UP) {
    		WatchUi.pushView(new Rez.Menus.MainMenu(), new MenuInput.MainMenuInputDelegate(), Ui.SLIDE_UP);
    		return true;
		} else if (evt.getKey() == Ui.KEY_ENTER) {
    		WatchUi.pushView(new RangeCalculatorView(), null, Ui.SLIDE_IMMEDIATE);
    		return true;
		}
    	return false;
    }
}