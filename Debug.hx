package gaxe;

import openfl.Assets;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.geom.ColorTransform;
import openfl.display.Bitmap;
import openfl.display.FPS;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;
import openfl.display.DisplayObjectContainer;
import openfl.geom.Rectangle;
import openfl.Lib;
import openfl.text.TextField;
import openfl.text.Font;
import openfl.text.TextFormat;
import openfl.events.KeyboardEvent;
import openfl.media.Sound;

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
        #if (android )//|| neko)
        trace( msg + "\n" );// + haxe.CallStack.toString(haxe.CallStack.callStack() ) );
        #end

        debug.text = msg+"\n"+debug.text;
    }

}
