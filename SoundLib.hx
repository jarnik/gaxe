package gaxe;

import openfl.Assets;
//import nme.AssetData;
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
//import motion.Actuate;
//import motion.easing.Linear;

class SoundInstance {
    public var volume:Float;
    public var channel:SoundChannel;
	public function new( channel:SoundChannel, volume:Float ) { 
		this.volume = volume;
		this.channel = channel;
	}
}

class SoundLib
{
    
    public static var sounds:Map<String,Sound>;
    private static var cache:Array<SoundInstance>;
    private static var master:Float;
    private static var music:Sound;
    private static var musicChannel:SoundChannel;
	
	private static var soundFileExtension:String;
	private static var musicFileExtension:String;

    public static function init( _master:Float, list:Array<String> ):Void {
		#if flash
			musicFileExtension = ".mp3";
		#else
			musicFileExtension = ".ogg";
		#end
		
		#if neko
			soundFileExtension = ".ogg";
		#else
			soundFileExtension = ".mp3";
		#end
		
        master = _master; 
        cache = [];
        sounds = new Map<String,Sound>();
        for ( item in list )
            preload( item );

    }

	public static function autoInit( _master:Float = 1 ):Void {
		// edit your c:\Program Files\nme\haxe\lib\nme\3,4,2\templates\default\flash\haxe\nme\installer\Assets.hx
		// edit your c:\Program Files\nme\haxe\lib\nme\3,4,2\templates\default\haxe\nme\installer\Assets.hx
		// to make resourceTypes public 
		//AssetData.initialize();
		
		#if !flash
			soundFileExtension = ".ogg";
			musicFileExtension = ".ogg";
		#else
			soundFileExtension = ".mp3";
			musicFileExtension = ".ogg";
		#end
		
		/*
		var soundAssets:Array<String> = [];
		for ( k in Assets.type.keys() ) {
			if ( Assets.type.get( k ) == SOUND  
				&& StringTools.endsWith( k, soundFileExtension ) ) {
				soundAssets.push( k );
			}
		}
		init( _master, soundAssets );
		*/
		init( _master, [] );
	}
	
    private static function preload( url:String ):Void {
        var sound:Sound = sounds.get( url );
        if ( sound == null ) {
            sound = Assets.getSound( url );
            sounds.set( url, sound );
        }
    }

    public static function play( url:String, volume:Float = 1, loop:Bool = false, fade:Float = 0 ):SoundChannel  {
		url += soundFileExtension;
        var sound:Sound = sounds.get( url );
        if ( sound == null ) {
            sound = Assets.getSound( url );
            sounds.set( url, sound );
        }
		var loops:Int = ( loop ? 1000 : 0 );
        var channel:SoundChannel = sound.play( 0, loops, new SoundTransform( fade == 0 ? volume*master : 0 ) );
        addChannel( channel, channel.soundTransform.volume );
        channel.addEventListener( Event.SOUND_COMPLETE, onSoundComplete );
		if ( fade != 0 )
			fadeIn( channel, fade, volume );
		return channel;
    }
	
	private static function onUpdateChannelVolume( si:SoundInstance ):Void {
		setChannelVolume( si.channel, si.volume );
	}

	public static function setChannelVolume(channel:SoundChannel, volume:Float):Void
	{
		var t:SoundTransform = new SoundTransform( volume * master, 0 );
		/*#if neko
			channel.nmeSetTransform( t );
		#else*/
			channel.soundTransform = t;
		//#end
	}
	
	public static function fadeOut( channel:SoundChannel, fadeOut:Float, keepRunning:Bool = false ):Void {
		var si:SoundInstance = fetchSoundInstance( channel );
		/*
		if ( keepRunning )
			Actuate.tween( si, fadeOut, { volume:0 } ).onUpdate( onUpdateChannelVolume, [ si ] ).ease( Linear.easeNone );
		else
			Actuate.tween( si, fadeOut, { volume:0 } ).onUpdate( onUpdateChannelVolume, [ si ] ).onComplete( stopChannel, [ channel ] ).ease( Linear.easeNone );
			*/
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
			
		var si:SoundInstance = fetchSoundInstance( channel );
		//Actuate.tween( si, fadeIn, { volume:volume } ).onUpdate( onUpdateChannelVolume, [ si ] ).ease( Linear.easeNone );
	}

    private static function addChannel( channel:SoundChannel, volume:Float ):Void {
        var si:SoundInstance = new SoundInstance( channel, volume );
        cache.push( si );
    }
	
	private static function fetchSoundInstance( channel:SoundChannel ):SoundInstance {
		for ( si in cache )
			if ( si.channel == channel )
				return si;
		return null;
	}

    private static function onSoundComplete( e:Event ):Void {
        //Debug.log( "sound complete "+e.target );
        var channel:SoundChannel = e.target;
		stopChannel( channel );        
    }

    public static function setMasterVolume( vol:Float ):Void {
        master = vol;
        for ( si in cache ) {
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
		if ( music == null )
			return null;
        #if android
            musicChannel = music.play( 0, -1 , new SoundTransform( fade == 0 ? volume*master : 0 ));
			// edit c:\Program Files\nme\haxe\lib\nme\3,4,2\templates\default\android\template\src\org\haxe\nme\Sound.java playMusic and set mp.setLooping( true );
        #else
            musicChannel = music.play( 0, 1000 , new SoundTransform( fade == 0 ? volume*master : 0 ));
        #end
        addChannel( musicChannel, volume );
		if ( fade != 0 ) {
			fadeIn( musicChannel, fade, volume );
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
		if ( channel == musicChannel ) {
			musicChannel = null;
			music = null;
		}
	}
	

}
