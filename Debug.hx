package jarnik.gaxe;

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

        debugLayer = new Sprite();
        debug = new TextField(); 
        debug.defaultTextFormat = format;
        debug.height = Gaxe.h - 20;
        debug.width = Gaxe.w * Gaxe.upscale;
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

        Lib.current.stage.addEventListener( KeyboardEvent.KEY_UP, keyHandler );

        //Lib.current.stage.addChild( new FPS( 10, 10, 0xffffff ) );
        return debugLayer;
    }

    public static function showLog():Void {
        debugLayer.visible = true;
    }
	
    public static function keyHandler( e:KeyboardEvent ):Void {
        switch ( e.keyCode ) {
            case 219:
                debugLayer.visible = !debugLayer.visible;
            default:
        }
    }

    public static function log( msg:String ):Void {
        if ( buffer == null )
            buffer = "";
        if ( debug == null ) {
            buffer = msg+"\n"+buffer;
            return;
        }
        #if android
        trace( msg );
        #end

        debug.text = msg+"\n"+debug.text;
    }

}
