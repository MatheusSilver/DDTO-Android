package;

import openfl.system.System;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import lime.utils.Assets;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.display3D.textures.Texture;
import openfl.media.Sound;
#if cpp
import cpp.vm.Gc;
#elseif hl
import hl.Gc;
#elseif java
import java.vm.Gc;
#elseif neko
import neko.vm.Gc;
#end

using StringTools;

class Paths
{
	inline public static var SOUND_EXT = "ogg";

	public static var dumpExclusions:Array<String> = [
		'assets/images/Credits_LeftSide.png',
		'assets/images/DDLCStart_Screen_Assets.png',
		'assets/images/voltar_simples.png',
		'assets/images/backdropsmenu/backdropcatfight.png' /*, //Não esparava que isso fosse ser tão importante.
		'assets/music/freakyMenu.$SOUND_EXT',
		'assets/music/disco.$SOUND_EXT'*/
	];

	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static var currentTrackedTextures:Map<String, Texture> = [];
	public static var currentTrackedSounds:Map<String, Sound> = [];

	/// haya I love you for the base cache dump I took to the max
	//Esse código não foi roubado de uma adaptação feita para outro projeto, fonte: Confia :sunglasses:

	public static function excludeAsset(key:String):Void {
		if (!dumpExclusions.contains(key))
			dumpExclusions.push(key);
	}

	public static function clearUnusedMemory()
	{
		// clear non local assets in the tracked assets list
		var counter:Int = 0;
		for (key in currentTrackedAssets.keys())
		{
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key))
			{
				var obj = currentTrackedAssets.get(key);
				if (obj != null)
				{
					var isTexture:Bool = currentTrackedTextures.exists(key);
					if (isTexture)
					{
						var texture = currentTrackedTextures.get(key);
						texture.dispose();
						texture = null;
						currentTrackedTextures.remove(key);
					}
					@:privateAccess
					if (openfl.Assets.cache.hasBitmapData(key))
					{
						openfl.Assets.cache.removeBitmapData(key);
						FlxG.bitmap._cache.remove(key);
					}
					obj.destroy();
					currentTrackedAssets.remove(key);
					counter++;
				}
			}
		}
		// run the garbage collector for good measure lmfao
		#if (cpp || neko || java || hl)
		Gc.run(true);
		#end
	}

	public static var localTrackedAssets:Array<String> = [];

	public static function clearStoredMemory(?cleanUnused:Bool = false)
	{
		// clear anything not in the tracked assets list
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null && !currentTrackedAssets.exists(key))
			{
				openfl.Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				obj.destroy();
			}
		}

		// clear all sounds that are cached
		for (key in currentTrackedSounds.keys())
		{
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key) && key != null)
			{
				Assets.cache.clear(key);
				currentTrackedSounds.remove(key);
			}
		}
		// flags everything to be cleared out next unused memory clear
		localTrackedAssets = [];
	}

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	public static function getPath(file:String, type:AssetType, ?library:Null<String> = null)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath:String = '';
			if (currentLevel != 'shared')
			{
				levelPath = getLibraryPathForce(file, currentLevel);
				if (OpenFlAssets.exists(levelPath, type))
					return levelPath;
			}

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		var returnPath = '$library:assets/$library/$file';
		return returnPath;
	}

	//X02: "Acho que não vai ser usado pra muita coisa"

	//Sílvio fazendo uma gambiarra gigantesca nos diálogos só com isso k
	//E com isso, os créditos voltam a funcionar da forma como deveriam tambem kek
	inline static public function imagechecker(key:String, ?library:String):Bool
	{
		return OpenFlAssets.exists(getPath('images/$key.png', IMAGE, library));
	}

	inline static public function imagesimple(key:String, ?library:String):String
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline public static function getPreloadPath(file:String = '')
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	inline static public function video(key:String, ?library:String)
	{
		return getPath('videos/$key.mp4', BINARY, library);
	}

	static public function sound(key:String, ?library:String)
	{
		return returnSound('sounds', key, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + Random.randUInt(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return returnSound('music', key, library);
	}

	inline static public function voices(song:String, ?prefix:String = '', ?suffix:String = ''):Any
	{
		#if html5
		return 'songs:assets/songs/${song.toLowerCase()}/${prefix}Voices${suffix}.$SOUND_EXT';
		#else
		var songKey:String = '${song.toLowerCase()}/${prefix}Voices${suffix}';
		var voices = returnSound('songs', songKey);
		return voices;
		#end
	}

	inline static public function inst(song:String):Any
	{
		#if html5
		return 'songs:assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
		#else
		var songKey:String = '${song.toLowerCase()}/Inst';
		var inst = returnSound('songs', songKey);
		return inst;
		#end
	}

	inline static public function formatToSongPath(path:String)
	{
		return path.toLowerCase().replace(' ', '-');
	}

	inline static public function image(key:String, ?library:String, ?locale:Bool, usaGPU:Bool = false):FlxGraphic
	{
		var returnAsset:FlxGraphic = returnGraphic(key, library, locale, usaGPU);
		return returnAsset;
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function fileExists(key:String, type:AssetType, ?library:String)
	{
		if (OpenFlAssets.exists(Paths.getPath(key, type, library)))
			return true;

		return false;
	}

	inline static public function getSparrowAtlas(key:String, ?library:String, ?locale:Bool, usaGPU:Bool = true)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library, locale, usaGPU), file('images/$key.xml', library));
	}

	inline static public function getSparrowAtlassimple(key:String, ?library:String, ?locale:Bool)
	{
		return FlxAtlasFrames.fromSparrow(imagesimple(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		var imageLoaded:FlxGraphic = returnGraphic(key, library, false, true);

		return FlxAtlasFrames.fromSpriteSheetPacker((imageLoaded != null ? imageLoaded : image(key, library)), file('images/$key.txt', library));
	}

	public static function returnGraphic(key:String, ?library:String, ?locale:Bool, usarGPU:Bool = false)
	{
		var path:String = getPath('images/$key.png', IMAGE, library);
		#if (debug && !mobile)
		trace('carregando $path');
		#end
	if (OpenFlAssets.exists(path))
	{
		if (!currentTrackedAssets.exists(key))
		{
			var bitmap = OpenFlAssets.getBitmapData(path);
			var newGraphic:FlxGraphic;
				if (SaveData.gpuTextures && usarGPU)
			{
				var texture = FlxG.stage.context3D.createTexture(bitmap.width, bitmap.height, BGRA, true, 0);

				texture.uploadFromBitmapData(bitmap);
				currentTrackedTextures.set(key, texture);
				bitmap.dispose();
				bitmap.disposeImage();
				bitmap = null;
				newGraphic = FlxGraphic.fromBitmapData(openfl.display.BitmapData.fromTexture(texture), false, key, false);
			}
			else
			{
				newGraphic = FlxGraphic.fromBitmapData(bitmap, false, key, false);
			}
			newGraphic.destroyOnNoUse = false;
			newGraphic.persist = true;
			currentTrackedAssets.set(key, newGraphic);
		}
		localTrackedAssets.push(key);
		return currentTrackedAssets.get(key);
	}
	trace('graphic is returning null at $key');
	return null;
	}

	public static function returnSound(path:String, key:String, ?library:String)
	{
		var file:String = getPath(path == 'songs' ? '$key.$SOUND_EXT' : '$path/$key.$SOUND_EXT', SOUND, path == 'songs' ? path : library);
		#if (debug && !mobile)
		trace('carregando $file'); //Apenas pra eu ter uma noção melhor dos carregamentos desncessauros que esse mod tá fazendo.
		#end
		if (OpenFlAssets.exists(file))
		{
			if (!currentTrackedSounds.exists(file))
				currentTrackedSounds.set(file, OpenFlAssets.getSound(file));

			localTrackedAssets.push(key);
			return currentTrackedSounds.get(file);
		}

		FlxG.log.error('oh no $file is returning null NOOOO');
		return null;
	}
}
