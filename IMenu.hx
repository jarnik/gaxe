package gaxe;

import nme.display.DisplayObject;

interface IMenu {
    function show( state:EnumValue, params:Dynamic = null ):Void;
    function update( elapsed:Float ):Void;
	function resize( width:Float, height:Float ):Void;
    function getDisplayObject():DisplayObject;
    function hide():Void;
    function init( params:Dynamic ):Void;
    function isVisible():Bool;
}

