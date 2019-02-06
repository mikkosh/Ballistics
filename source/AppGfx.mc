using Toybox.Graphics as Gfx;
using Toybox.Math as Math;

using Toybox.WatchUi as Ui;


module AppGfx {

	const DIR_DOWN = 180;
	const DIR_LEFT = 270;
	const DIR_UP = 0;
	const DIR_RIGHT = 90;
	
	function transformPolygon(x, y, arrShape, degrees, sizeMultiplier) 
	{		
		if(degrees > 360) {
			degrees = degrees - 360;
		}
	
		sizeMultiplier = sizeMultiplier.abs();
    	if(sizeMultiplier == 0) {
    		sizeMultiplier = 1;
		}
		var transform = new [arrShape.size()];
		for(var i = 0; i < arrShape.size(); i++) {
		
			var transX = ((arrShape[i][0] * Math.cos(degrees*Math.PI/180)) - (arrShape[i][1] * Math.sin(degrees*Math.PI/180))).toNumber();
            var transY = ((arrShape[i][0] * Math.sin(degrees*Math.PI/180)) + (arrShape[i][1] * Math.cos(degrees*Math.PI/180))).toNumber();
            transform[i] = [ (x+sizeMultiplier*transX).toNumber(), (y+sizeMultiplier*transY).toNumber()];
		}
		return transform;
	}
	
	function directionArrow(dc, x, y, direction, size) 
	{
		dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
    	dc.fillPolygon(transformPolygon(x, y, 
    				[ 	[0,-7], 
						[7, 7], 
						[-7, 7]
					], direction, size));
	}

}

class DirectionArrow extends Ui.Drawable {

    var angleDegrees; // 0 deg = up to down, 90 = rtl, 180 = down to up, 270 = ltr

    function initialize(options) {
    	
    	Drawable.initialize(options);
        if(options.hasKey(:angle)) {
            angleDegrees = options[:angle];
        } else {
            angleDegrees = 0;
        }
    }

    function draw(dc) {
    	
    	width = width ? width : dc.getWidth()/2;
    	height = height ? height : dc.getHeight()/2;
    	
    	var size = (( width > height ) ? height : width) - 5;
    	var x = locX ? locX-(size/2) : dc.getWidth()/2;
    	var y = locY ? locY+(size/2) : dc.getHeight()/2;
    	
		dc.setColor(Gfx.COLOR_DK_BLUE, Gfx.COLOR_TRANSPARENT);
		dc.drawCircle(x, y, size); //13*
		
		dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
    	dc.fillPolygon( AppGfx.transformPolygon(x, y, 
					[ 	[0,-13], 
						[10, 13],
						[0, 5], 
						[-10, 13]
					], (angleDegrees + 180), (size/10.9)) );// make the arrow point correctly (to match the model)
					
    }

    function setAngle(index) {
       angleDegrees = index;
    }

    function getAngle(index) {
        return angleDegrees;
    }
    function getAngleIndex(angle) {
        return angleDegrees;
    }
}
