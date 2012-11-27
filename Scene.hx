package jarnik.gaxe;

import nme.Assets;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.events.TouchEvent;
import nme.geom.Point;
import nme.display.Bitmap;
import nme.display.FPS;
import nme.display.Graphics;
import nme.display.Sprite;
import nme.display.Stage;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.geom.Rectangle;
import nme.Lib;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.events.KeyboardEvent;
import nme.media.Sound;

class Scene extends Sprite 
{
    // settings
    private var keepCached:Bool;

    // scene vars
    private var created:Bool;
    private var scene:Scene;
    private var scenes:Hash<Scene>;
    private var state:Dynamic;

    // components
    private var sceneLayer:Sprite;
    private var menu( getMenu, never ):IMenu;
   
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
    
    // --------------- MENU ------------------------------------------------------- 

    public function showMenu():Void {
        menu.show( null );
    }
    private function getMenu():IMenu { return Gaxe.menu; }
    public function allowMenu():Bool { return true; }

    // --------------- SCENES ------------------------------------------------------- 

    public function switchScene( newScene:Class<Scene> ):Void {
        var id:String = Std.string( newScene );
        Debug.log("["+this+"] switching to scene: "+id);
        if ( scene != null ) {
            scene.visible = false;
		    sceneLayer.removeChild( scene );
        }
        scene = fetchScene( newScene );
        scene.visible = true;
		sceneLayer.addChild( scene );
    }

    private function fetchScene( sceneClass:Class<Scene> ):Scene {
    //private function fetchScene( sceneClass:Dynamic ):Scene {
        var id:String = Std.string( sceneClass );
        if ( scenes == null )
            scenes = new Hash<Scene>();

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
        handleSwitchState( id );
        state = id;        
    }
    private function handleSwitchState( id:Dynamic ):Void {} //override

    public function handleTouch( e:TouchEvent ):Void {} // override
}
