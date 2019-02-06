using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class RowSettingsView extends Ui.View {
	hidden var pageTitle = "";
	hidden var rows = {};
	hidden var index = 0;
	
	const FONT_ROW = Gfx.FONT_SMALL;
	const TEXT_MARGIN = 5;
	
	function initialize() {
		Ui.View.initialize();
	}
	
	function nextIndex() {
		if(index >= (rows.size()-1)) {
			index = 0;
		} else {
			index++;
		}
	}
	function prevIndex() {
		if(index <= 0) {
			index = rows.size()-1;
		} else {
			index--;
		}
	}
	function resetIndex() {
		index = 0;
	}
	
	function setTitle(title) {
		pageTitle = title;
	}
	function addRow(title, value) {
		rows[rows.size()] = [title,value];
	}
	function clearRows() {
		rows = {};
	}
    
    //! Update the view
    function onUpdate(dc) {
    	dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.clear();
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
		var font = Gfx.FONT_XTINY;
		var topPosition = dc.getFontHeight(font)+5;
		dc.drawText(dc.getWidth()/2, 5, font, pageTitle, Gfx.TEXT_JUSTIFY_CENTER);
		dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_BLACK);
		dc.drawLine(0, topPosition, dc.getWidth(), topPosition);
		
		var tableHeight = dc.getHeight() - topPosition;
    	var rowHeight = dc.getFontHeight(FONT_ROW)*1.2;
    	var rowKeys = rows.keys();
    	var longestTextWidth = 0;
    	var r = null;
    	for(var i=0; i < rowKeys.size(); i++) {
 
    		var textWidth = dc.getTextWidthInPixels(rows[rowKeys[i]][0], FONT_ROW);
    		if(textWidth > longestTextWidth) {
    			longestTextWidth = textWidth;
			}
    	}
    	
    	longestTextWidth = longestTextWidth+TEXT_MARGIN;
    	
    	for(var i=0; i < rowKeys.size(); i++) {
    		if((i+index) < rowKeys.size()) {
    			r = rows[rowKeys[i+index]];
			} else {
				r = rows[rowKeys[(i+index) - rowKeys.size()]];
			}
    		var rowTitle = r[0];
    		var rowValue = r[1];
    		var rowY = topPosition + i*rowHeight+rowHeight/2 - dc.getFontHeight(FONT_ROW)/2;
    		var valueX = longestTextWidth + 10 + (dc.getWidth() - (longestTextWidth + 10)) /2;
    		
    		dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_BLACK);
    		dc.drawText(longestTextWidth, rowY, FONT_ROW, rowTitle, Gfx.TEXT_JUSTIFY_RIGHT);
    		
    		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
    		dc.drawText(valueX, rowY, FONT_ROW, rowValue, Gfx.TEXT_JUSTIFY_CENTER);
    		
    		dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_BLACK);
    		dc.drawLine(0, topPosition+i*rowHeight, dc.getWidth(), topPosition+i*rowHeight);
    	}
    	dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_BLACK);
    	dc.drawLine(longestTextWidth+TEXT_MARGIN, topPosition, longestTextWidth+TEXT_MARGIN, dc.getHeight());
        //View.onUpdate(dc);   
    }
 
}
