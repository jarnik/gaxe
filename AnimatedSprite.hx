package gaxe;

import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Sprite;
import nme.geom.Point;
import nme.geom.Rectangle;

import nme.text.TextField;
import nme.text.TextFormat;

class AnimatedSprite extends Sprite
{
    private var frames:Array<Bitmap>;
    private var currentFrame:Int;

	public function new( url:String, ?width:Float, ?height:Float ) 
	{
        super();

        var bitmapData:BitmapData = Assets.getBitmapData( url );

        frames = [];

        var frameWidth:Float = bitmapData.height;
        var frameHeight:Float = bitmapData.height;
        if ( width != null )
            frameWidth = width;
        if ( height != null )
            frameHeight = height;
        var frameCount:Int = Std.int((bitmapData.width / frameWidth) * (bitmapData.height / frameHeight));
        var frame:Bitmap;
        var frameBitmapData:BitmapData;
        var rect:Rectangle = new Rectangle( 0, 0, frameWidth, frameHeight );
        var point:Point = new Point();  
        var offsetX:Int = 0;
        var offsetY:Int = 0;
        for ( i in 0...frameCount ) {
            frameBitmapData = new BitmapData( Std.int( frameWidth ), Std.int( frameHeight ) );
            rect.x = offsetX;
            rect.y = offsetY;
            frameBitmapData.copyPixels( bitmapData, rect, point );
            frame = new Bitmap( frameBitmapData, nme.display.PixelSnapping.AUTO );
            addChild( frame );
            frame.visible = false;
            frames.push( frame );
            offsetX += Std.int( frameWidth );
            if ( offsetX >= bitmapData.width ) {
                offsetX = 0;
                offsetY += Std.int( frameHeight );
            }
        }
        currentFrame = 0;        
        setFrame( 0 );
	}

   	public function setFrame( f:Int ):Void {
        if ( frames == null || frames.length <= f )  
            return;

        #if !flash
            //if (f == null)
            //   return;
        #end

        frames[ currentFrame ].visible = false;

        // !! win build has some problems with assighing this number directly 
        for ( i in 0...frames.length ) 
            if ( i == f ) 
                currentFrame = i;

        frames[ currentFrame ].visible = true;
    }

    public function getCurrentBitmap():Bitmap {
        return frames[ currentFrame ];
    }

    public function getFrameCount():Int { return frames.length; }
}
