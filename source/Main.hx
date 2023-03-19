package;

import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import lime.app.Application;
import webm.WebmPlayer;
import lime.system.System;
#if CRASH_HANDLER
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
#end

using StringTools;

class Main extends Sprite
{
	var game:FlxGame;
	var gameWidth:Int = 1280; // Width of the game in pixels
	var gameHeight:Int = 720; // Height of the game in pixels
	var initialState:Class<FlxState> = Init; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public static var path:String = System.applicationStorageDirectory;

	public static var fpsVar:FPS;
	public static var tongue:FireTongueEx;

	#if desktop
	public static var mouseVisivel:Bool = true;
	#elseif mobile
	public static var mouseVisivel:Bool = false;
	#end

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		// quick checks
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	public static var webmHandler:WebmHandler;

	private function setupGame():Void
	{
		#if (flixel < "5.0.0")
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}
		#end

		game = new FlxGame(gameWidth, gameHeight, initialState, #if (flixel < "5.0.0") zoom, #end framerate, framerate, skipSplash, startFullscreen);
		addChild(game);

		fpsVar = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsVar);

		if (fpsVar != null)
			fpsVar.visible = SaveData.showFPS;

		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end

		// Finish up loading debug tools.
		// NOTE: Causes Hashlink to crash, so it's disabled.
	}

	inline public static function isSteamDeck():Bool
	{
		return false;
	}

	// Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
	// very cool person for real they don't get enough credit for their work
	#if CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";

		errMsg += "\nUncaught Error: "
			+ e.error
			+ "\nPlease report this error to the GitHub page: https://github.com/Jorge-SunSpirit/Doki-Doki-Takeover\n\n> Crash Handler written by: sqirra-rng";

		Application.current.window.alert(errMsg, "Error!");
		Sys.exit(1);
	}
	#end
}