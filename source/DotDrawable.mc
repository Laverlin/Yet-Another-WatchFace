using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

/// Custom class to draw a line in layout
/// Allow to change line color in code
///
class DotDrawable extends Ui.Drawable 
{
    hidden var _x;
    hidden var _y;
    hidden var _color;

    function initialize(params) 
    {
        Drawable.initialize(params);

        _x = params.get(:x);
        _y = params.get(:y);
        _color = params.get(:color);
    }
    
    function setColor(color)
    {
    	_color = color;
    }
    
    function draw(dc) 
    {
    	dc.setColor(_color, Gfx.COLOR_TRANSPARENT);
        dc.fillRectangle(_x, _y, 4, 4);
    }
}