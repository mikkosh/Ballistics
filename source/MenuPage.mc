using Toybox.WatchUi as Ui;
using BallisticUnitConversions as BUC;
using Toybox.Graphics as Gfx;

module MenuInput {
	class MainMenuInputDelegate extends Ui.MenuInputDelegate {
	
		function initialize() {
			Ui.MenuInputDelegate.initialize();
		}
		
	  function onMenuItem(item) 
	  {
	  	var bp = Application.getApp().getBProp();
	  	var pf = new BUC.PropertyFormatter(bp);
		var inf = new BUC.InputFormatter();
	  	if (item == :menu_main_range) {
	  		
			Ui.pushView(new Ui.Picker({
				:title=>new Ui.Text({:text=>Lang.format("$1$ ($2$)", ["Range to target", pf.getRangeUnit()]), :locX =>Ui.LAYOUT_HALIGN_CENTER, :locY=>Ui.LAYOUT_VALIGN_BOTTOM, :color=>Gfx.COLOR_WHITE}), 
				:pattern=>[new NumberPickerFactory(0,inf.getRangeMax(),inf.getRangeStep(),{:font=>Gfx.FONT_NUMBER_MEDIUM})],
				:defaults=>[(pf.getTargetRange(false)/inf.getRangeStep())]
			}), new RangeInputDelegate(), Ui.SLIDE_IMMEDIATE);	
	  	
		} else if (item == :menu_main_angle) {
			
			Ui.pushView(new Ui.Picker({
				:title=>new Ui.Text({:text=>Lang.format("$1$ ($2$)", ["Shooting angle", "deg"]), :locX =>Ui.LAYOUT_HALIGN_CENTER, :locY=>Ui.LAYOUT_VALIGN_BOTTOM, :color=>Gfx.COLOR_WHITE}), 
				:pattern=>[new NumberPickerFactory(-90,90,5,{:font=>Gfx.FONT_NUMBER_MEDIUM})],
				:defaults=>[((90+bp.getShootingAngle())/5)]
			}), new AngleInputDelegate(), Ui.SLIDE_IMMEDIATE);
		
		} else if (item == :menu_main_windage) {
			
			Ui.pushView(new Ui.Picker({
				:title=>new Ui.Text({:text=>Lang.format("$1$ ($2$)", ["Wind speed", pf.getWindSpeedUnit()]), :locX =>Ui.LAYOUT_HALIGN_CENTER, :locY=>Ui.LAYOUT_VALIGN_BOTTOM, :color=>Gfx.COLOR_WHITE}), 
				:pattern=>[
					new NumberPickerFactory(0,inf.getWindSpeedMax(),inf.getWindSpeedStep(),{:font=>Gfx.FONT_NUMBER_MEDIUM}),
					new AnglePickerFactory(5)
				],
				:defaults=>[(pf.getWindSpeed(false)/inf.getWindSpeedStep()), bp.getWindAngle()	]
			}), new WindSpeedInputDelegate(), Ui.SLIDE_IMMEDIATE);	
		
		} else if (item == :menu_main_sight) {
			var view = new SightSettingsView();
			Ui.pushView(view, new SightSettingsInputDelegate(view), Ui.SLIDE_IMMEDIATE);
		} else if (item == :menu_main_reset) {
			Application.getApp().resetState();
		}
	  } 
	}
	
	class SettingsPickerDelegate extends Ui.PickerDelegate {
		var bp;
		var inf;
		function initialize() {
			Ui.PickerDelegate.initialize();
		}
		function onAccept(value){
			bp = Application.getApp().getBProp();
			inf = new BUC.InputFormatter();
			updateSetting(value);
			Ui.popView(Ui.SLIDE_IMMEDIATE);
		}
		function onCancel() {
			Ui.popView(Ui.SLIDE_IMMEDIATE);
		}
	}
	
	class RangeInputDelegate extends SettingsPickerDelegate {
		function initialize() {
			SettingsPickerDelegate.initialize();
		}
		function updateSetting(value) {
			bp.setTargetRange(inf.statuteTargetRange(value[0]));
		}
	}
	
	//! SHOOTING ANGLE
	class AngleInputDelegate extends SettingsPickerDelegate {
		function initialize() {
			SettingsPickerDelegate.initialize();
		}
		function updateSetting(value) {
			bp.setShootingAngle(value[0]);
		}
	}

	//! WIND SPEED
	class WindSpeedInputDelegate extends SettingsPickerDelegate {
		function initialize() {
			SettingsPickerDelegate.initialize();
		}
		function updateSetting(value) {
			bp.setWindSpeed(inf.statuteWindSpeed(value[0])); 
			bp.setWindAngle(value[1]);
		}
	}
}