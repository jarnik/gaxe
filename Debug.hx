package gaxe;

import nme.Assets;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.geom.Point;
import nme.geom.ColorTransform;
import nme.display.Bitmap;
import nme.display.FPS;
import nme.display.Graphics;
import nme.display.Sprite;
import nme.display.Stage;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.display.DisplayObjectContainer;
import nme.geom.Rectangle;
import nme.Lib;
import nme.text.TextField;
import nme.text.Font;
import nme.text.TextFormat;
import nme.events.KeyboardEvent;
import nme.media.Sound;

class Debug extends Sprite 
{

    private static var debug:TextField;
    private static var buffer:String;

    public static var font:Font;
    public static var format:TextFormat;
    private static var debugLayer:Sprite;

    public static function initLog():Sprite {
        font = Assets.getFont ("assets/fonts/nokiafc22.ttf");
        format = new TextFormat (font.fontName, 8, 0xFF0000);
        //format = new TextFormat (font.fontName, 8, 0xffffff);

        debugLayer = new Sprite();
        debug = new TextField(); 
        debug.defaultTextFormat = format;
        debug.selectable = false;
        debug.mouseEnabled = false;
        debug.embedFonts = true;
        debug.wordWrap = true;
        debug.x = 10;
        debug.y = 10;
        if ( buffer == null )
            buffer = "";
        debug.text = buffer;
        debugLayer.addChild(debug);

        debugLayer.mouseEnabled = false;
        debugLayer.visible = false;

        resize();

        //Lib.current.stage.addChild( new FPS( 10, 10, 0xffffff ) );
        return debugLayer;
    }

    public static function showLog():Void {
        debugLayer.visible = true;
    }
	
	public static function toggleLog():Void {
		debugLayer.visible = !debugLayer.visible;
	}
	
	public static function resize():Void {
		if ( debug == null )
			return;
		debug.height = Lib.current.stage.stageHeight - 20;
        debug.width = Lib.current.stage.stageWidth;
	}

    public static function log( msg:String ):Void {
        if ( buffer == null )
            buffer = "";
        if ( debug == null ) {
            buffer = msg+"\n"+buffer;
            return;
        }
        #if (android)// || neko)
        trace( msg );
        #end

        debug.text = msg+"\n"+debug.text;
    }

}
