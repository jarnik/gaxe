package gaxe;

import openfl.Assets;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.JoystickEvent;
import openfl.events.TouchEvent;
import openfl.geom.Point;
import openfl.geom.ColorTransform;
import openfl.display.Bitmap;
import openfl.display.FPS;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;
import openfl.display.StageDisplayState;
import openfl.geom.Rectangle;
import openfl.Lib;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.events.KeyboardEvent;
import openfl.media.Sound;

class Gaxe extends Scene 
{
    private static var inited:Bool;

    public static var fixedW:Int;
    public static var fixedH:Int;

    public static var w:Int;
    public static var h:Int;
    public static var upscale:Float;
    public static var head:Gaxe;
	
	private static var borders:Array<Sprite>;

    private static var timeElapsed:Float;
    private static var prevFrameTime:Float;
    private static var keysPressed:Map<String,Bool>;

    public static var mainMenu:IMenu;

    private function init():Void {}

    // touches
    public static var touchCount:Int;
    public static var touches:Array<Point>;

    public static function loadGaxe( _head:Gaxe, _menu:IMenu, _fixedW:Int = 0, _fixedH:Int = 0 ):Void {
        Gaxe.head = _head;
        Gaxe.mainMenu = _menu;
        fixedW = _fixedW;
        fixedH = _fixedH;
        touchCount = 0;
        touches = [];
		keysPressed = new Map<String,Bool>();

        _head.visible = false;
        if ( _menu != null ) {
            _menu.hide();
            Gaxe.head.addChild( _menu.getDisplayObject() );
        }
        Lib.current.stage.addChild( head );
        Lib.current.stage.addEventListener( Event.ENTER_FRAME, updateFrame );
        Lib.current.stage.addEventListener( Event.RESIZE, onResize );
        Lib.current.stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyHandler );
        Lib.current.stage.addEventListener( KeyboardEvent.KEY_UP, onKeyHandler );
        Lib.current.stage.addEventListener( JoystickEvent.BUTTON_DOWN, onJoyHandler );
        Lib.current.stage.addEventListener( JoystickEvent.BUTTON_UP, onJoyHandler );
        Lib.current.stage.addEventListener( JoystickEvent.HAT_MOVE, onJoyHandler );
        Lib.current.stage.addEventListener( JoystickEvent.AXIS_MOVE, onJoyHandler );

        #if android
        Lib.current.stage.addEventListener( TouchEvent.TOUCH_END, onTouchHandler );
        Lib.current.stage.addEventListener( TouchEvent.TOUCH_BEGIN, onTouchHandler );
        Lib.current.stage.addEventListener( TouchEvent.TOUCH_MOVE, onTouchHandler );
        #end
    }

	private static function updateFrame( e:Event ) {
        if ( !inited )
            initGaxe();

        var now:Float = Lib.getTimer() / 1000;
        timeElapsed = (now - prevFrameTime);
        prevFrameTime = now;
		
        if ( mainMenu != null &&  mainMenu.isVisible() )
            mainMenu.update( timeElapsed );        
        else
            head.update( timeElapsed );        
    }
	
	private static function onResize( e:Event ) {
		// image is 120x80
        // optimus is 480x320
        // flash 720x480
        if ( fixedW != 0 && fixedH != 0 ) {
            w = fixedW;
            h = fixedH;     
			var appRatio:Float = w / h;
			var stageRatio:Float = Lib.current.stage.stageWidth / Lib.current.stage.stageHeight;
			if ( stageRatio > appRatio )
				upscale = Lib.current.stage.stageHeight / h;
			else
				upscale = Lib.current.stage.stageWidth / w;
        } else {
            w = Lib.current.stage.stageWidth; 
            h = Lib.current.stage.stageHeight;
			upscale = 1;
        }
		head.x = ( Lib.current.stage.stageWidth - w  * upscale ) / 2;
		head.y = ( Lib.current.stage.stageHeight - h  * upscale ) / 2;
		setBorders( 
			head.y, 
			head.y, 
			head.x, 
			head.x 
		);
		Debug.log("resized "+w+" x "+h+" scale "+upscale);
        head.scaleX = upscale;
		head.scaleY = upscale;
		head.resize( w, h );
		mainMenu.resize( w, h );
		Debug.resize();
	}
	
	private static function setBorders( top:Float, bottom:Float, left:Float, right:Float ):Void {
		if ( borders == null ) {
			borders = [];
			var b:Sprite;
			for ( i in 0...4 ) {
				borders.push( b = new Sprite() );
				b.graphics.beginFill( 0, 1 );
				b.graphics.drawRect( 0, 0, 10, 10 );
				b.graphics.endFill();
				Lib.current.stage.addChild( b );
			}
		}
		// top
		borders[ 0 ].width = Lib.current.stage.stageWidth;
		borders[ 0 ].height = top;
		// bottom
		borders[ 1 ].width = Lib.current.stage.stageWidth;
		borders[ 1 ].height = bottom;
		borders[ 1 ].y = Lib.current.stage.stageHeight - bottom;
		// left
		borders[ 2 ].width = left;
		borders[ 2 ].height = Lib.current.stage.stageHeight;
		// right
		borders[ 3 ].width = right;
		borders[ 3 ].height = Lib.current.stage.stageHeight;
		borders[ 3 ].x = Lib.current.stage.stageWidth - right;
	}

    private static function initGaxe():Void {
        inited = true;

		Lib.current.stage.align = StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;        
        
        prevFrameTime = Lib.getTimer() / 1000;

        Debug.log("started...");
        //Debug.log("upscale "+upscale+" "+w+"x"+h);
        //Lib.current.stage.addChild( new Bitmap(Assets.getBitmapData( "assets/buttonRed.png" ), nme.display.PixelSnapping.AUTO, false ) );
        
		onResize( null );
		Lib.current.stage.addChild( Debug.initLog() );
		
        head.visible = true;

        head.init();
    }
	
	public static function setFullscreen( full:Bool = true ):Void {
		Debug.log("going "+ ( full ? "fullscreen" : "window" ) );
		Lib.current.stage.displayState = full ? StageDisplayState.FULL_SCREEN_INTERACTIVE : StageDisplayState.NORMAL;
	}
	
	public static function isFullscreen():Bool {
		return Lib.current.stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE;
	}

    public static function setGamma( gamma:Float ):Void {
        #if flash
        var mul:Float = 1.5 - gamma;
        var add:Float = 255*gamma - 128;
        var ct:ColorTransform = new ColorTransform( mul, mul, mul, 1, add, add, add );
        Lib.current.stage.transform.colorTransform = ct;
        #else
        #end
    }

    public function getCurrentScene():Scene {
        return scene;
    }

    private static function onKeyHandler( e:KeyboardEvent ):Void {
        #if android
            e.stopImmediatePropagation();
            e.stopPropagation();
            // Android - BACK = 27
            if ( e.type == KeyboardEvent.KEY_UP && e.charCode == 27 ) {
                if ( !mainMenu.isVisible() ) {
                    if ( head.scene.allowMenu() )
                        head.showMenu();
                } else
                    mainMenu.hide();
            }
        #else
			if (
				( e.type == KeyboardEvent.KEY_UP && keysPressed.get( Std.string( e.keyCode ) ) == null ) ||
				( e.type == KeyboardEvent.KEY_DOWN && keysPressed.get( Std.string( e.keyCode ) ) != null )
			)
				return;
				
			if ( e.type == KeyboardEvent.KEY_DOWN )
				keysPressed.set( Std.string( e.keyCode ), true );
			else
				keysPressed.remove( Std.string( e.keyCode ) );
		
            if ( e.type == KeyboardEvent.KEY_UP && e.charCode == 27 ) {
                if ( !mainMenu.isVisible() ) {
                    if ( head.scene.allowMenu() ) {
                        head.scene.showMenu();
					}
                } else
                    mainMenu.hide();
            }
			if ( e.type == KeyboardEvent.KEY_UP && e.keyCode == 219 ) {
				Debug.toggleLog();
			}
			head.handleKey( e );
			
			#if neko
			// ALT + F4 quit
			if ( (e.keyCode == 115 || e.keyCode == 83) && e.altKey ) {
				quit();
			}
			#end
        #end
    }

    private static function onJoyHandler( e:JoystickEvent ):Void {
        head.handleJoy( e );
    }
	
	public static function quit():Void {
		#if !flash
		Sys.exit( 0 );
		#end
	}

    private static function onTouchHandler( e:TouchEvent ):Void {
        var sendHandleEvent:Bool = true;
        switch ( e.type ) {
            case TouchEvent.TOUCH_BEGIN:
                touchCount++;
                touches[ e.touchPointID ] = new Point( e.stageX / upscale, e.stageY / upscale );
            case TouchEvent.TOUCH_END:
                touchCount--;
                touches[ e.touchPointID ] = null;
            case TouchEvent.TOUCH_MOVE:
                if ( 
                    Math.abs( touches[ e.touchPointID ].x - e.stageX / upscale ) > 0.5 ||
                    Math.abs( touches[ e.touchPointID ].y - e.stageY / upscale ) > 0.5
                ) {
                    touches[ e.touchPointID ].x = e.stageX / upscale;
                    touches[ e.touchPointID ].y = e.stageY / upscale;
                } else
                    sendHandleEvent = false;
        }
        if ( head != null && sendHandleEvent )
            head.handleTouch( e );
    }
	
	public static function switchGlobalScene( newScene:Class<Scene> ):Void {
		head.switchScene( newScene );
	}
	
	override public function handleKey( e:KeyboardEvent ):Void {
		getCurrentScene().handleKey( e );
	}

    override public function handleJoy( e:JoystickEvent ):Void {
        if ( getCurrentScene() != null )
        {
            getCurrentScene().handleJoy( e );
        }
    }

}
