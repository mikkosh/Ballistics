using BallisticsModel as BM;
class BallisticsProperties {
	
	hidden var prop;
	
	const KEY_RANGETARGET		= 0;
	const KEY_ANGLESHOOTING	= 1; // 1
	const KEY_ANGLEZERO	= 2; // 2
	const KEY_SPEEDWIND = 3; // 3
	const KEY_ANGLEWIND = 4; // 4
	const KEY_ANGLEZERO_CHECKSUM = 5;
	
	function initialize(properties) {
		if(properties != null) {
			prop = properties;
			//invalidZeroAngle = false;
		} else {
			prop = getRawDefaults();
			//invalidZeroAngle = true;
		}
	}
	hidden function getRawDefaults() {
		return [ 
			100, // KEY_RANGETARGET
			0.0, //KEY_ANGLESHOOTING	=> 
			0.0, //KEY_ANGLEZERO	=> 
			0.0,//KEY_SPEEDWIND => 
			0.0,//KEY_ANGLEWIND => 
			"invalid" // KEY_ANGLE_ZERO_CHECKSUM 
		];
	}
	hidden function setProp(name, value) {
		prop[name] = value;
	}
	
	hidden function getProp(name) {
		return prop[name];
	}
	
	function isInvalidZeroAngle() {
		return !getProp(KEY_ANGLEZERO_CHECKSUM).equals(getAngleZeroChecksum());
	}
	function getAngleZeroChecksum() {
		var chksum = Lang.format("$1$$2$$3$$4$$5$", [
			getZeroRange(),
			getDragFunction(),
			getDragCoefficient(),
			getInitialVelocity(),
			getSightHeight()
		]);
		return chksum;
	}
	function getState()
	{
		return prop;
	}	
	
	function setTargetRange(range) {
		setProp(KEY_RANGETARGET, range);
	}
	
	function getTargetRange() {
		return getProp(KEY_RANGETARGET);
	}
	
	
	function getZeroRange() {
		var val = Application.getApp().getProperty("ZeroRange");
		if(val instanceof Toybox.Lang.String) {
			val = val.toFloat();
		}
		return (val <= 0) ? 1 : val;
	}
	
	function getDragFunction() {
		var setting = Application.getApp().getProperty("DragFunction");
		if(setting instanceof Toybox.Lang.String) {
			setting = setting.toNumber();
		}
		if(setting == 1) {
			return BM.DRAG_G1;
		} else if(setting == 2) {
			return BM.DRAG_G2;
		} else if(setting == 5) {
			return BM.DRAG_G5;
		} else if(setting == 6) {
			return BM.DRAG_G6;
		} else if(setting == 7) {
			return BM.DRAG_G7;
		} else {
			return BM.DRAG_G8;
		}
	}
	
	function getDragCoefficient() {
		var val = Application.getApp().getProperty("DragCoefficient");
		if(val instanceof Toybox.Lang.String) {
			val = val.toFloat();
		}
		return (val <= 0) ? 0.1 : val;
	}
	
	
	function getInitialVelocity() {
		var val = Application.getApp().getProperty("InitialVelocity");
		if(val instanceof Toybox.Lang.String) {
			val = val.toFloat();
		}
		return (val <= 0) ? 1 : val;
	}
	
	function getSightHeight() {
		var val = Application.getApp().getProperty("SightHeight");
		if(val instanceof Toybox.Lang.String) {
			val = val.toFloat();
		}
		return (val <= 0) ? 1 : val;
	}
	
	function setShootingAngle(shootingAngle){
		setProp(KEY_ANGLESHOOTING, shootingAngle);
	}
	function getShootingAngle() {
		return getProp(KEY_ANGLESHOOTING);
	}
	

	function setZeroAngle(zAngle){
		setProp(KEY_ANGLEZERO, zAngle);
		setProp(KEY_ANGLEZERO_CHECKSUM, getAngleZeroChecksum());
	}
	function getZeroAngle() {
		return getProp(KEY_ANGLEZERO);
	}

	function setWindSpeed(windSpeed){
		setProp(KEY_SPEEDWIND, windSpeed);
	}
	function getWindSpeed() {
		return getProp(KEY_SPEEDWIND);
	}
	
	function setWindAngle(windAngle) {
		setProp(KEY_ANGLEWIND, windAngle);
	}
	function getWindAngle() {
		return getProp(KEY_ANGLEWIND);
	}
	
	function getSightMoa() {
		// http://www.traditionaloven.com/tutorials/angle/convert-angular-mil-unit-to-angle-unit-minute.html
		var setting = Application.getApp().getProperty("ClickValue");
		if(setting instanceof Toybox.Lang.String) {
			setting = setting.toNumber();
		}
		if(setting == 14) {
			return 0.25;
		} else if(setting == 12) {
			return 0.5;
		} else if(setting == 1) {
			return 1;
		} else if (setting == 169500) { // 0.1mil = 169/500MOA, 0.3375
			return 0.3375;
		} else if (setting == 2740) { // 0.2mil = 27/40MOA, 0.6750
			return 0.6750;
		}
		return 0;
	}	
}