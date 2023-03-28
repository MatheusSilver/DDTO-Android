package;

import flixel.FlxG;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import flixel.addons.transition.FlxTransitionableState;
import lime.utils.Assets;
import openfl.Lib;

using StringTools;

class CoolUtil
{

	public static function difficultyString(diff:Int):String
	{
		var difficultyArray:Array<String> = [
			'Fácil',
			'Normal',
			'Difícil'
		];

		return difficultyArray[diff];
	}

	public static function internalDifficultyString(diff:Int):String
	{
		var difficultyArray:Array<String> = ['Easy', 'Normal', 'Hard'];
		return difficultyArray[diff];
	}

	public static function getWeekName(data:Dynamic):String
	{
		switch (data)
		{
			case 0 | 'prologue':
				return 'Prologue';
			case 1 | 'sayori':
				return 'Sayori';
			case 2 | 'natsuki':
				return 'Natsuki';
			case 3 | 'yuri':
				return 'Yuri';
			case 4 | 'monika':
				return 'Monika';
			case 5 | 'festival':
				return 'Festival';
			case 6 | 'encore':
				return 'Encore';
			case 7 | 'protag':
				return 'Protag';
			case 8 | 'side':
				return 'Side';
		}

		return null;
	}

	inline public static function boundTo(value:Float, min:Float, max:Float):Float
	{
		return Math.max(min, Math.min(max, value));
	}

	public static function coolText(path:String):String
	{
		var daList:String = Assets.getText(path).trim();
		return daList;
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function coolStringFile(path:String):Array<String>
	{
		var daList:Array<String> = path.trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	public static function getFPSCap():Int
	{
		return Std.int(Lib.current.stage.frameRate);
	}

	public static function setFPSCap(cap:Int):Void
	{
		Main.setFPSCap(cap);
	}

	public static function flixelSaveCheck(company:String, title:String, localPath:String = 'ninjamuffin99', name:String = 'funkin', newPath:Bool = false):Bool
	{
		return true;
	}

	public static function renpySaveCheck(?doki:String = 'DDLC-1454445547'):Bool
	{
		return true;
	}

	public static function ddlcpSaveCheck():Bool
	{
		return true;
	}

	public static function getUsername():String
	{
		return "Jogador";
	}

	public static function openURL(url:String)
	{
		FlxG.openURL(url);
	}

	public static function precacheSound(sound:String, ?library:String = null):Void
	{
		Paths.sound(sound, library);
	}

	public static function precacheMusic(sound:String, ?library:String = null):Void
	{
		Paths.music(sound, library);
	}

	public static function precacheInst(sound:String):Void
	{
		Paths.inst(sound);
	}

	public static function precacheVoices(sound:String, ?prefix:String = '', ?suffix:String = ''):Void
	{
		Paths.voices(sound, prefix, suffix);
	}


	public static function calcSectionLength(multiplier:Float = 1.0):Float
	{
		return (Conductor.stepCrochet / (64 / multiplier)) / Conductor.playbackSpeed;
	}
}