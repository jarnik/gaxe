package jarnik.gaxe;

import nme.Assets;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.geom.Point;
import nme.display.Bitmap;
import nme.display.FPS;
import nme.display.Graphics;
import nme.display.Sprite;
import nme.display.Stage;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.display.DisplayObject;
import nme.geom.Rectangle;
import nme.Lib;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.events.KeyboardEvent;
import nme.media.Sound;

interface IMenu {
    function show( state:EnumValue, params:Dynamic = null ):Void;
    function update( elapsed:Float ):Void;
    function getDisplayObject():DisplayObject;
    function hide():Void;
    function init( params:Dynamic ):Void;
    function isVisible():Bool;
}

