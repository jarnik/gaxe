package gaxe;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.geom.Point;
import openfl.geom.Rectangle;

import openfl.text.TextField;
import openfl.text.TextFormat;

typedef Animation =
{
    frames: Array<Int>,
    fps: Float
}

class AnimatedSprite extends Sprite
{

    public var fps:Float = 0;
    public var randomFrames:Bool = false;

    private var frames:Array<Bitmap>;
    private var currentFrame:Int;

    private var timer:Float = 0;
    public var loop:Bool = true;

    private var animations:Map<String,Animation>;
    private var currentAnimation:String;
    private var currentAnimationFrame:Int = 0;

	public function new( url:String, width:Float = 0, height:Float = 0 )
	{
        super();
        animations = new Map<String,Animation>();
        currentAnimation = null;
        setImage(url, width, height);
    }

    public function setImage(url:String, width:Float = 0, height:Float = 0 ):Void
    {
        var bitmapData:BitmapData = Assets.getBitmapData( url );

        frames = [];

        var frameWidth:Float = bitmapData.height;
        var frameHeight:Float = bitmapData.height;
        if ( width !=  0  )
            frameWidth = width;
        if ( height != 0 )
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
            frame = new Bitmap( frameBitmapData, openfl.display.PixelSnapping.AUTO );
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

    public function getCurrentFrame():Int {
        return currentFrame;
    }

    public function getFrame(frame:Int):BitmapData {
        return frames[ frame ].bitmapData;
    }

    public function update(elapsed:Float):Void
    {
        if (this.fps != 0)
        {
            this.timer += elapsed;
            if ( this.timer > Math.abs(1/this.fps) )
            {
                this.timer = 0;
                var frame:Int;
                if ( this.randomFrames )
                {
                    frame = Math.floor( this.getFrameCount() * Math.random() );
                } if (this.currentAnimation != null)
                {
                    var animationFrames:Int = this.animations[this.currentAnimation].frames.length;
                    this.currentAnimationFrame = (this.currentAnimationFrame + 1) % animationFrames;
                    frame = this.animations[this.currentAnimation].frames[this.currentAnimationFrame];
                    if (!this.loop && this.currentAnimationFrame == animationFrames-1)
                    {
                        // stop
                        this.currentAnimation = null;
                        this.currentAnimationFrame = 0;
                        this.fps = 0;
                    }
                }
                else
                {
                    frame = (currentFrame + (fps > 0 ? 1 : -1 ));
                    if (!this.loop)
                    {
                        if (
                            ((this.fps > 0) && (frame >= this.getFrameCount() - 1 )) ||
                            ((this.fps < 0) && (frame <= 0))
                        ) {
                            this.fps = 0; // stop
                        }
                    }
                    frame = (frame + this.getFrameCount()) % this.getFrameCount();
                }
                this.setFrame( frame );
            }
        }
    }

    public function getFrameCount():Int { return frames.length; }

    public function addAnimation(name:String, frames:Array<Int>, fps:Float):Void
    {
        this.animations[name] = {frames:frames,fps:fps};
    }

    public function playAnimation(name:String, loop:Bool = false, delayedStart:Float = 0):Void
    {
        if (this.currentAnimation == name)
        {
            return;
        }
        this.loop = loop;
        this.currentAnimation = name;
        this.currentAnimationFrame = 0;
        this.fps = this.animations[name].fps;
        this.timer = -delayedStart; // set to positive value to delay playback
        setFrame(this.animations[name].frames[0]);
    }
}
