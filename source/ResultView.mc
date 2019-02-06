using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using BallisticUnitConversions as BUC;
using BallisticsModel;

class ResultView extends Ui.View 
{
	
	hidden var rf;
	
	function initialize(result) {
		self.rf = result;
		Ui.View.initialize();
	}
	
    //! Load your resources here
    function onLayout(dc) 
    {
    	setLayout(Rez.Layouts.ResultLayout(dc));
    	
    }
	
    //! Update the view
    function onUpdate(dc) 
    {
    	var bp = Application.getApp().getBProp();
    	var pf = new BUC.PropertyFormatter(bp);

		View.findDrawableById("id_range").setText(Lang.format("$1$ $2$$3$", ["TARGET AT",pf.getTargetRange(true),pf.getRangeUnit()]));
      	
		var clicksH = null;
		var clicksV = null;
    	var p = null; // positioning helper variable

   
        View.findDrawableById("id_drop_at").setText(rf.getPath(true));
        View.findDrawableById("id_driftdrop_lbl").setText(Lang.format("DROP/DRIFT($1$)",[rf.getPathUnit()]));
   		// new	
		View.findDrawableById("id_velo_at").setText(Lang.format("$1$$2$",[rf.getVelo(),rf.getVeloUnit()]));
	    View.findDrawableById("id_time_at").setText(Lang.format("$1$$2$",[rf.getTime(),rf.getTimeUnit()]));
	    View.findDrawableById("id_drift_at").setText(rf.getDrift(true)); 
		// :new
   
        // Vertical clicks   
        clicksV = BallisticsModel.calculateClickCorrection(rf.getCorrMoa(), bp.getSightMoa());
    	if(clicksV.abs() > 99) {
    		View.findDrawableById("id_clicks_ud").setText("--");
    	} else {
    		View.findDrawableById("id_clicks_ud").setText(clicksV.abs().toString());
    	}
    	// Horizontal clicks
    	clicksH = BallisticsModel.calculateClickCorrection(rf.getWindageMoa(), bp.getSightMoa());
    	if(clicksH.abs() > 99) {
    		View.findDrawableById("id_clicks_lr").setText("--");
    	} else {
    		View.findDrawableById("id_clicks_lr").setText(clicksH.abs().toString());
    	}
    	
    	View.onUpdate(dc);
    	
    	p = View.findDrawableById("gfx_clicks_ud_indicator");
    	if(clicksV < 0) {
    		AppGfx.directionArrow(dc, p.locX, p.locY, AppGfx.DIR_DOWN, 1);
    	} else {
    		AppGfx.directionArrow(dc, p.locX, p.locY, AppGfx.DIR_UP, 1);
    	}
    	p = View.findDrawableById("gfx_clicks_lr_indicator");
    	if(clicksH < 0) {
    		AppGfx.directionArrow(dc, p.locX, p.locY, AppGfx.DIR_LEFT, 1);
    	} else {
    		AppGfx.directionArrow(dc, p.locX, p.locY, AppGfx.DIR_RIGHT, 1);
    	}
    	
    	p = View.findDrawableById("gfx_drop_ud_indicator");
    	if(rf.getPath(false) <= 0) { 
    		AppGfx.directionArrow(dc,p.locX, p.locY, AppGfx.DIR_DOWN, 1);
		} else {
			AppGfx.directionArrow(dc,p.locX, p.locY, AppGfx.DIR_UP, 1);
		}
		
		p = View.findDrawableById("gfx_drift_lr_indicator");
    	if(rf.getDrift(false) <= 0) { 
    		AppGfx.directionArrow(dc,p.locX, p.locY, AppGfx.DIR_RIGHT, 1);
		} else {
			AppGfx.directionArrow(dc,p.locX, p.locY, AppGfx.DIR_LEFT, 1);
		}
		
    	return true;
    }
    
}

class ResultInputDelegate extends Ui.InputDelegate 
{
	function initialize() {
		Ui.InputDelegate.initialize();
	}
 	// @param evt KEY_XXX enum value
    //! @return true if handled, false otherwise
    function onKey(evt) 
    {	
    	if (evt.getKey() == Ui.KEY_ESC) {
    		Ui.switchToView(new BallisticsView(), new BallisticsInputDelegate(), Ui.SLIDE_DOWN );
    		//Ui.popView(Ui.SLIDE_DOWN); // calculator
    		return true;
		}
    	return false;
    }
}