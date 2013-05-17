package gaxe;

import nme.Assets;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.geom.Point;
import nme.display.Bitmap;
import nme.display.BitmapData;
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
import nme.media.SoundChannel;
import nme.media.SoundTransform;

typedef SoundInstance = {
    var volume:Float;
    var channel:SoundChannel;
}

class SoundLib
{
    
    public static var sounds:Hash<Sound>;
    private static var cache:Array<SoundInstance>;
    private static var master:Float;
    private static var music:Sound;
    private static var musicChannel:SoundChannel;
	
	private static var soundFileExtension:String;
	private static var musicFileExtension:String;

    public static function init( _master:Float, list:Array<String> ):Void {
        master = _master; 
        cache = [];
        sounds = new Hash<Sound>();
        for ( item in list )
            //preload( "assets/sfx/"+item );
            preload( item );

    }

	public static function autoInit( _master:Float = 1 ):Void {
		// edit your c:\Program Files\nme\haxe\lib\nme\3,4,2\templates\default\flash\haxe\nme\installer\Assets.hx
		// edit your c:\Program Files\nme\haxe\lib\nme\3,4,2\templates\default\haxe\nme\installer\Assets.hx
		// to make resourceTypes public 
		Assets.initialize();
		
		#if neko
			soundFileExtension = ".ogg";
			musicFileExtension = ".ogg";
		#else
			soundFileExtension = ".mp3";
			musicFileExtension = ".ogg";
		#end
		
		var soundAssets:Array<String> = [];
		for ( k in Assets.resourceTypes.keys() ) {
			if ( Assets.resourceTypes.get( k ) == "sound"  
				&& StringTools.endsWith( k, soundFileExtension ) ) {
				soundAssets.push( k );
			}
		}
		init( _master, soundAssets );
	}
	
    private static function preload( url:String ):Void {
        var sound:Sound = sounds.get( url );
        if ( sound == null ) {
            sound = Assets.getSound( url );
            sounds.set( url, sound );
        }
    }

    public static function play( url:String, volume:Float = 1, loop:Bool = false ):SoundChannel  {
        //url = "assets/sfx/"+url;
		url += soundFileExtension;
        var sound:Sound = sounds.get( url );
        if ( sound == null ) {
            sound = Assets.getSound( url );
            sounds.set( url, sound );
        }
		var loops:Int = 0;
        #if windows
           loops = ( loop ? -1 : 0 );
        #else
            loops = ( loop ? 1000 : 0 );
        #end
        var channel:SoundChannel = sound.play( 0, loops, new SoundTransform( volume * master ) );
        addChannel( channel, volume );
        channel.addEventListener( Event.SOUND_COMPLETE, onSoundComplete );
		return channel;
    }

    private static function addChannel( channel:SoundChannel, volume:Float ):Void {
        var si:SoundInstance = { channel: channel, volume: volume };
        //Debug.log("caching "+si);
        cache.push( si );
    }

    private static function onSoundComplete( e:Event ):Void {
        //Debug.log( "sound complete "+e.target );
        var channel:SoundChannel = e.target;
        for ( s in cache ) {
            if ( s.channel != channel )
                continue;
            cache.remove( s );
            //Debug.log( "decaching "+s );
            break;
        }
    }

    public static function setMasterVolume( vol:Float ):Void {
        //Debug.log("setting master "+vol);
        master = vol;
        for ( si in cache ) {
            //Debug.log("setting master "+vol+" "+si);
            si.channel.soundTransform = new SoundTransform( si.volume * master, 0 );
        }
    }

    public static function playMusic( url:String ):SoundChannel {
		url += musicFileExtension;
        var sound:Sound = sounds.get( url );
        if ( sound == null ) {
            sound = Assets.getSound( url );
            sounds.set( url, sound );
        }
        if ( sound == music )
            return musicChannel;

        stopMusic();
        music = sound;   
        #if android
            musicChannel = music.play( 0, -1 , new SoundTransform( 1 * master ));
			// edit c:\Program Files\nme\haxe\lib\nme\3,4,2\templates\default\android\template\src\org\haxe\nme\Sound.java playMusic and set mp.setLooping( true );
        #else
            musicChannel = music.play( 0, 1000 , new SoundTransform( 1 * master ));
        #end
        //Debug.log("music running, hopefully");
        addChannel( musicChannel, 1 );
		return musicChannel;
    }

    public static function stopMusic():Void {
        if ( musicChannel != null ) {
            musicChannel.stop();
            musicChannel = null;
			music = null;
        }
    }

}
