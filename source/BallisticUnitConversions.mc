using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

module BallisticUnitConversions {

	const CONV_YDS_TO_M = 0.9144; // yards to meters
	const CONV_MPH_TO_MPS = 0.44704; // miles per hour to meters per second
	const CONV_IN_TO_CM = 2.54;
	const CONV_FPS_TO_MPS = 0.3048;
	
	function getRangeUnit() {
		if((Sys.getDeviceSettings().distanceUnits == Sys.UNIT_METRIC)) {
			return "m";
		}else{
			return "yd";
		}
	}
	
	function getWindSpeedUnit() {
		if((Sys.getDeviceSettings().distanceUnits == Sys.UNIT_METRIC)) {
			return "m/s";
		}else{
			return "mph";
		}
	}

	function getShootingAngleUnit() {
		return Ui.loadResource(Rez.Strings.deg);
	}

	function getPathUnit() {
		if((Sys.getDeviceSettings().distanceUnits == Sys.UNIT_METRIC)) {
			return "cm";
		}else{
			return "in";
		}
	}
	function getTimeUnit() {
		return "s";
	}
	function getVeloUnit() {
		if((Sys.getDeviceSettings().distanceUnits == Sys.UNIT_METRIC)) {
			return "m/s";
		}else{
			return "fps";
		}
	}
	
	class PropertyFormatter {
		
		hidden var unitMetric;
		hidden var bp;
		
		function initialize(properties) 
		{
			self.unitMetric = (Sys.getDeviceSettings().distanceUnits == Sys.UNIT_METRIC);
			self.bp = properties;
			
		}
		
		function isMetric() {
			return unitMetric;
		}
		
		function getTargetRange(asString) {
			var val = bp.getTargetRange();
			if(unitMetric) {
				val = CONV_YDS_TO_M * val;
			}
			if(asString) {
				return val.format("%03d");
			}
			return val;
		}
		
		
		
		function getWindSpeed(asString) {
			var val = bp.getWindSpeed();
			if(unitMetric) {
				val = CONV_MPH_TO_MPS * val;
			}
			if(asString) {
				return val.format("%2d");
			}
			return val;
		}
		
		function getShootingAngle() {
			return bp.getShootingAngle().format("%2d");
		}
		
		function getSightHeightUnit() {
			if(unitMetric) {
				return "cm";
			}else{
				return "in";
			}
		}
		function getSightHeight(asString) {
			var val = bp.getSightHeight();
			var formatStr = "%2.2f";
			if(unitMetric) {
				val = CONV_IN_TO_CM * val;
				formatStr = "%2.1f";
			}
			
			if(asString) {
				return val.format(formatStr);
			}
			return val;
		}
		
		function getZeroRange(asString) {
			var val = bp.getZeroRange();
			if(unitMetric) {
				val = CONV_YDS_TO_M * val;
			}
			if(asString) {
				return val.format("%2.0d");
			}
			return val;
		}
		function getInitialVelocityUnit() {
			if(unitMetric) {
				return "m/s";
			}else{
				return "fps";
			}
		}
		function getInitialVelocity(asString) {
			var val = bp.getInitialVelocity();
			if(unitMetric) {
				val = CONV_FPS_TO_MPS * val;
			}
			if(asString) {
				return val.format("%2.1d");
			}
			return val;
		}
		function getSightMoa(asString) {
			var moaval = bp.getSightMoa();
			if(!asString) {
				return moaval;
			}
			var str = "unknown";
			if(moaval > 0.24 && moaval < 0.26) {
				str = "1/4 MOA";
			} else if(moaval > 0.49 && moaval < 0.51) {
				str = "1/2 MOA";
			} else if(moaval > 0.99 && moaval < 1.1) {
				str = "1 MOA";
			} else if(moaval > 0.337 && moaval < 0.338) {// 0.3375MOA = 0.1mil
				str = "0.1 mil";
			}else if(moaval > 0.67 && moaval < 0.68) {// 0.6750MOA = 0.2mil
				str = "0.2 mil";
			}
			return str;
		}
	}
	class ResultFormatter {
		
		hidden var unitMetric;
		hidden var res;
		
		hidden var range;
		hidden var path;
		hidden var corrMOA;
		hidden var velo;
		hidden var velox;
		hidden var veloy;
		hidden var time;
		hidden var windage;
		hidden var windageMOA;
		
		
		function initialize(pRange, pPath, pCorrMOA, pVelo, pVelox, pVeloy, pTime, pWindage, pWindageMOA) 
		{
			self.unitMetric = (Sys.getDeviceSettings().distanceUnits == Sys.UNIT_METRIC);
			self.range = pRange;
			self.path = pPath;
			self.corrMOA = pCorrMOA;
			self.velo = pVelo;
			self.velox = pVelox;
			self.veloy = pVeloy;
			self.time = pTime;
			self.windage = pWindage;
			self.windageMOA = pWindageMOA;
		
		}
		function isMetric() {
			return unitMetric;
		}
		
		function getPath(asString) {
			var val = self.path;
			if(unitMetric) {
				val = CONV_IN_TO_CM * val;
			}
			// returns an ABSOLUTE value (direction indicated by arrows)
			if(asString) {
				if(val.abs() > 10) {
					return val.abs().format("%2.0f");
				}
				return val.abs().format("%2.1f");
			}
			return val;
		}
		
		function getDrift(asString) {
			var val = self.windage;
			if(unitMetric) {
				val = CONV_IN_TO_CM * val;
			}
			if(asString) {
				// returns an ABSOLUTE value
				if(val.abs() > 10) {
					return val.abs().format("%2.0f");
				}
				return val.abs().format("%2.1f");
			}
			return val;
		}
		
		
		
		function getVelo() {
			var val = self.velo;
			if(unitMetric) {
				val = CONV_FPS_TO_MPS * val;
				return val.format("%2.0f");
			}
			return val.format("%2.0f");
		}
		
		function getTime() {
			return self.time.format("%2.1f");
		}
		
		function getCorrMoa() {
			return self.corrMOA;
		}
		
		function getWindageMoa() {
			return self.windageMOA;
		}
		
	}
	
	class InputFormatter {
		hidden var unitMetric;
		function initialize() 
		{
			self.unitMetric = (Sys.getDeviceSettings().distanceUnits == Sys.UNIT_METRIC);
		}
		
		function getRangeStep() {
			return 10;
		}
		function getRangeMax() {
			return 1000;
		}
		function getInitialRange() {
			if(unitMetric) {
				return 100/CONV_YDS_TO_M;
			}
			return 100;
		}
		function statuteTargetRange(value) {
			if(unitMetric) {
				return value/CONV_YDS_TO_M;
			}
			return value;
		}
		function getWindSpeedMax() {
			if(unitMetric) {
				return 25;
			}
			return 25/CONV_MPH_TO_MPS;
		}
		function getWindSpeedStep() {
			return 1;
		}
		function statuteWindSpeed(value) {
			if(unitMetric) {
				return value/CONV_MPH_TO_MPS;
			}
			return value;
		}
		

	}

}