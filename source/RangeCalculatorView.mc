using Toybox.WatchUi as Ui;
using Toybox.Timer as Timer;
using Toybox.Graphics as Gfx;

class RangeCalculatorView extends Ui.ProgressBar
{
	hidden var zaSolver;
	hidden var resultSolver;
	hidden var timer = null;
	hidden var progressBar;
	const ITERATIONS_MAX = 100;
	
	function initialize()
    {
    	var bp = Application.getApp().getBProp();
    	self.zaSolver = new ZeroAngleResolver(
			bp.getDragFunction(), 
			bp.getDragCoefficient(), 
			bp.getInitialVelocity(), 
			bp.getSightHeight(), 
			bp.getZeroRange(),
			0.0
		);
		var atmCorr = 1; // no atmCorrection
		if(Application.getApp().getProperty("UseAtmCorr")) {
			Sensor.setEnabledSensors( [Sensor.SENSOR_TEMPERATURE] );
	    	var nfo = Sensor.getInfo(); 
	    	var pressure = (nfo.pressure == null) ? 29.53 : 0.000295301 * nfo.pressure;
	    	var altitude = (nfo.altitude == null) ? 0 : 3.28084 * nfo.altitude;
	    	var temperature = (nfo.temperature == null) ? 59 : nfo.temperature * 1.8 + 32;
			var corr = BallisticsModel.atmCorrect(
				1, // DragCoefficient, use 1 to get the corr
				altitude, //altitude m => ft
				pressure, // pressure Pa => Hg conversion
				temperature, //temp C => F
				0.78); // standard relative humidity, as there are no sensor data available
		}
		self.resultSolver = new RangeResolver(
				bp.getTargetRange(),
				bp.getDragFunction(), 
				bp.getDragCoefficient() * atmCorr, 				
				bp.getInitialVelocity(), 
				bp.getSightHeight(),
				bp.getShootingAngle(), 
				bp.getZeroAngle(), 
				bp.getWindSpeed(), 
				bp.getWindAngle()
			);
	 	//bp.resetTouched();
	 	
	 	Ui.ProgressBar.initialize("Initializing rifle", null);
	 	timer = new Timer.Timer();
		timer.start( method(:timerCallback), 100, true );
		
    }

   
    function timerCallback() {
     		var bp = Application.getApp().getBProp();
     		var rangeReady = false;
     		var zeroReady = !bp.isInvalidZeroAngle();
     		if(!zeroReady) {
     			
     			setDisplayString("Initializing rifle");
     			for(var i = 0; i < ITERATIONS_MAX && !zeroReady; i++) {
     				
     				zeroReady = zaSolver.iterate();
					if(zeroReady) {
					
						bp.setZeroAngle(zaSolver.getResult());
						self.resultSolver = new RangeResolver(
							bp.getTargetRange(),
							bp.getDragFunction(), 
							bp.getDragCoefficient(), 				
							bp.getInitialVelocity(), 
							bp.getSightHeight(),
							bp.getShootingAngle(), 
							bp.getZeroAngle(), 
							bp.getWindSpeed(), 
							bp.getWindAngle()
						);
						break;
					}
	    		}
     		} else {
     			self.zaSolver = null;//new
     			setDisplayString("Calculating ballistics");
     			for(var i = 0; i < ITERATIONS_MAX && !rangeReady; i++) {
	    			rangeReady = resultSolver.iterate();
	    		}
     		}
     		
    		if(rangeReady && zeroReady) {
    			timer.stop();
    			timer = null;
    			Ui.popView(Ui.SLIDE_IMMEDIATE);
    			Ui.switchToView(new ResultView(resultSolver.getResult()), new ResultInputDelegate(), Ui.SLIDE_DOWN ); //new ResultInputDelegate()
				self.resultSolver = null;
				self.zaSolver = null;
 			} 
    }

}