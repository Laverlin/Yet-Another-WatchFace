using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

/// Custom class to draw a line in layout
/// Allow to change line color in code
///
class LineDrawable extends Ui.Drawable 
{
    hidden var _x1, _x2;
    hidden var _y1, _y2;
    hidden var _lineColor;

    function initialize(params) 
    {
        Drawable.initialize(params);

        _x1 = params.get(:x1);
        _x2 = params.get(:x2);
        _y1 = params.get(:y1);
        _y2 = params.get(:y2);
        _lineColor = params.get(:lineColor);
    }
    
    function setColor(color)
    {
    	_lineColor = color;
    }
    
    function draw(dc) 
    {
    	dc.setColor(_lineColor, Gfx.COLOR_TRANSPARENT);
        dc.drawLine(_x1, _y1, _x2, _y2);
    }
}