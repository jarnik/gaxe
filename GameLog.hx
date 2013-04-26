package gaxe; 

import haxe.remoting.AMFConnection;
import nme.errors.Error;

class GameLog
{
		
	private static var _gatewayURL:String;
	private static var connection:AMFConnection;
	private static var _appName:String;		
	private static var _sessionID:String;

    public static var started:Bool = false;
	
	public static function init( appName:String, gatewayURL:String ):Void {
		_gatewayURL = gatewayURL;
		_appName = appName;
        if ( _sessionID == null )
    		_sessionID = Std.string( Math.floor(Math.random() * 10000000) );
	}

    public static function start():Void {
        if ( _gatewayURL == null )
            return;
		
        #if flash
        started = true;
        try {
            connection = AMFConnection.urlConnect( _gatewayURL );
            connection.setErrorHandler( onError );
        } catch ( e : Error ) {
            started = false;
        }
        #else
        started = false;
        #end
    }

	public static function log( data : Dynamic ):Void {
		// Send the data to the remote server. 
		if ( started && connection != null ) {
			connection.GameLog.log.call( [ _appName, _sessionID, data ] , onResult );
        }
	}

    private static function onResult( r : Dynamic ):Void {
        //r;
    }

    private static function onError( e : Dynamic ):Void {
        //Str.string( e );
    }

}
