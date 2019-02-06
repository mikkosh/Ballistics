using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;


class NumberPickerFactory extends Ui.PickerFactory {
    hidden var mStart;
    hidden var mStop;
    hidden var mIncrement;
    hidden var mFormatString;
    hidden var mFont;

    function getIndex(value) {
        var index = (value / mIncrement) - mStart;
        return index;
    }

    function initialize(start, stop, increment, options) {
        
        Ui.PickerFactory.initialize();
        
        mStart = start;
        mStop = stop;
        mIncrement = increment;

        if(options != null) {
            mFormatString = options.get(:format);
            mFont = options.get(:font);
        }

        if(mFont == null) {
            mFont = Gfx.FONT_NUMBER_HOT;
        }

        if(mFormatString == null) {
            mFormatString = "%d";
        }
    }

    function getDrawable(index, selected) {
        return new Ui.Text( { :text=>getValue(index).format(mFormatString), :color=>Gfx.COLOR_WHITE, :font=> mFont, :locX =>Ui.LAYOUT_HALIGN_CENTER, :locY=>Ui.LAYOUT_VALIGN_CENTER } );
    }

    function getValue(index) {
        return mStart + (index * mIncrement);
    }

    function getSize() {
        return ( mStop - mStart ) / mIncrement + 1;
    }

}
class AnglePickerFactory extends Ui.PickerFactory {
   var dirArr;
   var inc;

    function initialize(increment) {
    	Ui.PickerFactory.initialize();
    	
    	dirArr = new DirectionArrow({});
        inc = increment;
    
    }

    function getIndex(value) {
        return value/inc;
    }

    function getSize() {
        return 360 / inc;
    }

    function getValue(index) {
        return index * inc;
    }

    function getDrawable(index, selected) {
        dirArr.setAngle(getValue(index));
        return dirArr;
    }
}
