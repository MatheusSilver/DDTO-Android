package;

import firetongue.Replace;

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
				font = 'Aller';
			case 'riffic':
				font = 'Riffic Free Bold';
			case 'halogen':
				font = 'Halogen';
			case 'grotesk':
				font = 'HK Grotesk Bold';
			case 'pixel':
				font = 'LanaPixel';
			case 'dos':
				font = 'Perfect DOS VGA 437 Win';
			case 'vcr':
				font = 'VCR OSD Mono';
			case 'waifu':
				if (SaveData.language == "en-US")
					font = 'CyberpunkWaifus';
				else
					font = 'LanaPixel';

			case 'lang':
				// ok, essa fonte é bem pesada... mas é universal
				font = 'Go Noto Current Regular';
		}

		return font;
	}

	public static function getFontOffset(type:String = 'aller'):Float
	{
		var offset:Float = 0;

		if (type.toLowerCase() == 'pixel' || type.toLowerCase() == 'waifu') {
			// none because they all use LanaPixel
			return 0;
		} else {
			return offset;
		}
	}

	public static function getString(flag:String, context:String = 'data', ?replace:Dynamic):String
	{
		var str:String = Main.tongue.get(flag, context);

		if (replace != null)
			str = Replace.flags(str, ["<X>"], [Std.string(replace)]);

		return str;
	}
}
