package;

import firetongue.Replace;
import flixel.FlxG;

using StringTools;

// for reference: https://www.techonthenet.com/js/language_tags.php
class LangUtil
{
	public static function getFont(type:String = 'aller'):String
	{
		var font:String = '';

		switch (type.toLowerCase())
		{
			default: // aller
				switch (SaveData.language)
				{
					default:
						font = 'Aller';
				}
			case 'riffic':
				switch (SaveData.language)
				{
					default:
						font = 'Riffic Free Bold';
				}
			case 'halogen':
				switch (SaveData.language)
				{
					default:
						font = 'Halogen';
				}
			case 'grotesk':
				switch (SaveData.language)
				{
					default:
						font = 'HK Grotesk Bold';
				}
			case 'pixel':
				switch (SaveData.language)
				{
					default:
						font = 'LanaPixel';
				}
			case 'dos':
				switch (SaveData.language)
				{
					default:
						font = 'Perfect DOS VGA 437 Win';
				}
			case 'vcr':
				switch (SaveData.language)
				{
					default:
						font = 'VCR OSD Mono';
				}
		}

		return font;
	}

	public static function getFontOffset(type:String = 'aller'):Float
	{
		var offset:Float = 0;

		switch (type.toLowerCase())
		{
			default:
			case 'pixel':
				// none because they all use LanaPixel
		}

		return offset;
	}

	public static function getString(flag:String, context:String = 'data', ?replace:Dynamic):String
	{
		var str:String = Main.tongue.get(flag, context);

		if (replace != null)
			str = Replace.flags(str, ["<X>"], [Std.string(replace)]);

		return str;
	}
}
