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
import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Linear;

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

    public static function play( url:String, volume:Float = 1, loop:Bool = false, fadeIn:Float = 0 ):SoundChannel  {
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
		volume *= master;
        var channel:SoundChannel = sound.play( 0, loops, new SoundTransform( fadeIn == 0 ? volume : 0 ) );
        addChannel( channel, volume );
        channel.addEventListener( Event.SOUND_COMPLETE, onSoundComplete );
		if ( fadeIn != 0 )
			Actuate.transform( channel, fadeIn ).sound( volume * master ).ease( Linear.easeNone );
		return channel;
    }
	
	public static function fadeOut( channel:SoundChannel, fadeOut:Float, keepRunning:Bool = false ):Void {
		if ( keepRunning )
			Actuate.transform( channel, fadeOut ).sound( 0 ).ease( Linear.easeNone );
		else
			Actuate.transform( channel, fadeOut ).sound( 0 ).onComplete( stopChannel, [ channel ] ).ease( Linear.easeNone );
	}
	
	public static function fadeIn( channel:SoundChannel, fadeIn:Float, volume:Float ):Void {
		/*
		 v Neko nefunguji gettery/settery pro SoundChannel
		  - nastavit nmeSetTransform / nmeGetTransform na public
		  - vsude v TransformActuator pridat
		    #if neko
				target.nmeSetTransform( endSoundTransform );
			#end
			
			#if neko
				start = target.nmeGetTransform();
				endSoundTransform = target.nmeGetTransform();
			#end
		 * 
		 * */
		
		Actuate.transform( channel, fadeIn ).sound( volume * master ).ease( Linear.easeNone );
	}

    private static function addChannel( channel:SoundChannel, volume:Float ):Void {
        var si:SoundInstance = { channel: channel, volume: volume };
        //Debug.log("caching "+si);
        cache.push( si );
    }

    private static function onSoundComplete( e:Event ):Void {
        //Debug.log( "sound complete "+e.target );
        var channel:SoundChannel = e.target;
		stopChannel( channel );        
    }

    public static function setMasterVolume( vol:Float ):Void {
        //Debug.log("setting master "+vol);
        master = vol;
        for ( si in cache ) {
            //Debug.log("setting master "+vol+" "+si);
            si.channel.soundTransform = new SoundTransform( si.volume * master, 0 );
        }
    }

    public static function playMusic( url:String, volume:Float = 1, fade:Float = 0 ):SoundChannel {
        var sound:Sound = null;
		if ( url != null ) {
			url += musicFileExtension;
			sound = sounds.get( url );
			if ( sound == null ) {
				sound = Assets.getSound( url );
				sounds.set( url, sound );
			}
		}
        if ( sound == music )
            return musicChannel;

		if ( fade != 0 && musicChannel != null )	
			fadeOut( musicChannel, fade );
		else
			stopMusic();
        music = sound;   
		volume *= master;
		if ( music == null )
			return null;
        #if android
            musicChannel = music.play( 0, -1 , new SoundTransform( fade == 0 ? volume : 0 ));
			// edit c:\Program Files\nme\haxe\lib\nme\3,4,2\templates\default\android\template\src\org\haxe\nme\Sound.java playMusic and set mp.setLooping( true );
        #else
            musicChannel = music.play( 0, 1000 , new SoundTransform( fade == 0 ? volume : 0 ));
        #end
        //Debug.log("music running, hopefully");
        addChannel( musicChannel, 1 );
		if ( fade != 0 ) {
			Actuate.transform( musicChannel, fade ).sound( volume * master ).ease( Linear.easeNone );
		}
		return musicChannel;
    }

    public static function stopMusic():Void {
        if ( musicChannel != null ) {
            musicChannel.stop();
            musicChannel = null;
			music = null;
        }
    }
	
	private static function stopChannel( channel:SoundChannel ):Void {
		channel.stop();
		for ( s in cache ) {
            if ( s.channel != channel )
                continue;
            cache.remove( s );
            //Debug.log( "decaching "+s );
            break;
        }
	}
	

}
