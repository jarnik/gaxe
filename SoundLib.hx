package jarnik.gaxe;

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
    
    private static var sounds:Hash<Sound>;
    private static var cache:Array<SoundInstance>;
    private static var master:Float;
    private static var music:Sound;
    private static var musicChannel:SoundChannel;

    public static function init( _master:Float, list:Array<String> ):Void {
        master = _master; 
        cache = [];
        sounds = new Hash<Sound>();
        for ( item in list )
            preload( "assets/sfx/"+item );

    }

    public static function preload( url:String ):Void {
        var sound:Sound = sounds.get( url );
        if ( sound == null ) {
            sound = Assets.getSound( url );
            sounds.set( url, sound );
        }
    }

    public static function play( url:String, volume:Float = 1 ):Void {
        url = "assets/sfx/"+url;
        var sound:Sound = sounds.get( url );
        if ( sound == null ) {
            sound = Assets.getSound( url );
            sounds.set( url, sound );
        }
        var channel:SoundChannel = sound.play( 0, 0, new SoundTransform( volume * master ) );
        addChannel( channel, volume );
        channel.addEventListener( Event.SOUND_COMPLETE, onSoundComplete );
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

    public static function playMusic( url:String ):Void {
        var sound:Sound = sounds.get( url );
        if ( sound == null ) {
            sound = Assets.getSound( url );
            sounds.set( url, sound );
        }
        if ( sound == music )
            return;

        stopMusic();
        music = sound;   
        #if android
            musicChannel = music.play( 0, -1 , new SoundTransform( 1 * master ));
        #else
            musicChannel = music.play( 0, 1000 , new SoundTransform( 1 * master ));
        #end
        //Debug.log("music running, hopefully");
        addChannel( musicChannel, 1 );
    }

    public static function stopMusic():Void {
        if ( musicChannel != null ) {
            musicChannel.stop();
            musicChannel = null;
        }
    }

}
