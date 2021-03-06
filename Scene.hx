package gaxe;

import openfl.Assets;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.events.JoystickEvent;
import openfl.geom.Point;
import openfl.display.Bitmap;
import openfl.display.FPS;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;
import openfl.geom.Rectangle;
import openfl.Lib;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.events.KeyboardEvent;
import openfl.media.Sound;

class Scene extends Sprite 
{
    // settings
    private var keepCached:Bool;

    // scene vars
    private var created:Bool;
    private var scene:Scene;
    private var scenes:Map<String,Scene>;
    private var state:Dynamic;

    // components
    private var sceneLayer:Sprite;
    private var menu( get_menu, never ):IMenu;
   
    /*
    has multiple states
    only one can be active at the time

    two methods:

    i have multiple scenes, want to show only of them
    - class based  - scene == class  

    i have multiple components, want them to behave differently
    - switch based - state == internal switch & update handlers

    ??? can enum be translated to a string?
    */

    public function new() {
        super();
        created = false;

        keepCached = true;

        addChild( sceneLayer = new Sprite() );

        addEventListener( Event.ADDED_TO_STAGE, onCreate );
    }

    private function onCreate( e:Event ):Void {
        if ( !created ) {
            //if ( stage != null )
            //    stage.addEventListener( Event.RESIZE, onResize );
            created = true;
            create();
        }
        onReset();
    }

    private function create():Void {}

    private function onReset():Void {
        if ( !created )
            return;

        reset();
    }

    private function reset():Void {}
	
    public function log( msg:String ):Void {
        Debug.log( msg );
    }

    public function update( elapsed:Float ):Void {
        if ( scene != null )
            scene.update( elapsed );
    }

    /*private function onResize( e:Event ):Void {
        if ( stage != null ) {
            Gaxe.w = stage.stageWidth;
            Gaxe.h = stage.stageHeight;
        }
        resize( Gaxe.w, Gaxe.h );
    }   */ 

    public function resize( width:Float, height:Float ):Void {
		if ( scene != null )
			scene.resize( width, height );
    }
    
    // --------------- MENU ------------------------------------------------------- 

    public function showMenu():Void {
        menu.show( null );
    }
    private function get_menu():IMenu { return Gaxe.mainMenu; }
    public function allowMenu():Bool { return true; }

    // --------------- SCENES ------------------------------------------------------- 

    public function switchScene( newScene:Class<Scene> ):Void {
        var id:String = Type.getClassName( newScene );
        trace("["+this+"] switching to scene: "+id);
        if ( scene != null ) {
            scene.visible = false;
		    sceneLayer.removeChild( scene );
        }
        scene = fetchScene( newScene );
        scene.visible = true;
		sceneLayer.addChild( scene );
		refocus();
    }
	
	private function refocus():Void  {
		stage.focus = this;
		stage.focus = null;
	}

    private function fetchScene( sceneClass:Class<Scene> ):Scene {
    //private function fetchScene( sceneClass:Dynamic ):Scene {
        var id:String = Type.getClassName( sceneClass );
        if ( scenes == null )
            scenes = new Map<String,Scene>();

        var scene:Scene = scenes.get( id );
        if ( scene != null ) {
            Debug.log("got cached: "+id);
            return scene;
        }

        Debug.log("creating new "+id);
        scene = Type.createInstance( sceneClass, [] );
        scenes.set( id, scene );
        return scene;
    }

    // --------------- STATES ------------------------------------------------------- 
    
    public function switchState( id:Dynamic ):Void {
        Debug.log("["+this+"] switching to state: "+id);
        if ( handleSwitchState( id ) )
			state = id;        
    }
    private function handleSwitchState( id:Dynamic ):Bool { return true; } //override

    public function handleTouch( e:TouchEvent ):Void { } // override
	
    public function handleKey( e:KeyboardEvent ):Void {} // override

    public function handleJoy( e:JoystickEvent ):Void {} // override
}
