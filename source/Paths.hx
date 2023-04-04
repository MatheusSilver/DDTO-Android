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

	private static var currentTrackedAssets:Map<String, Map<String, Dynamic>> = ["textures" => [], "graphics" => [], "sounds" => []];
	private static var localTrackedAssets:Map<String, Array<String>> = ["graphics" => [], "sounds" => []];
	private static var noDisposeTextures:Array<String> = [];


	public static final extensions:Map<String, String> = ["image" => "png", "audio" => "ogg", "video" => "mp4"];

	public static final limites:Array<Int> = [500, 600, 700]; //Esperança para 1gb de RAM, mas tenho certeza que isso não será suficiente para Love n' Funkin, Libitina e outras pesadonas.

	public static var dumpExclusions:Array<String> = [];

	public static function excludeAsset(key:String):Void {
		if (!dumpExclusions.contains(key))
			dumpExclusions.push(key);
	}

	public static function limparspriteporchave(chave:String, library:String){ //Isso é uma tentativa desesperada de arrumar libitina
		
		var key:String = getPath('images/$chave.png', IMAGE, library);
		@:privateAccess{
		if (currentTrackedAssets["textures"].exists(key) && !noDisposeTextures.contains(key))
			{
				var texture:Null<Texture> = currentTrackedAssets["textures"].get(key);
				texture.dispose();
				#if (debug && !mobile)
				trace('limpando $key das texturas');
				#end
				texture = null;
				currentTrackedAssets["textures"].remove(key);
			}

			var graphic:Null<FlxGraphic> = currentTrackedAssets["graphics"].get(key);
			OpenFlAssets.cache.removeBitmapData(key);
			FlxG.bitmap._cache.remove(key);
			graphic.destroy();
			#if debug
				trace('Removendo $key');
			#end
			currentTrackedAssets["graphics"].remove(key);
			localTrackedAssets["graphics"].remove(key);
		}
	}

	public static function clearUnusedMemory(runG:Bool = true):Void {
		for (key in currentTrackedAssets["graphics"].keys()) {
			@:privateAccess
			if (!localTrackedAssets["graphics"].contains(key)) {
				if (currentTrackedAssets["textures"].exists(key) && !noDisposeTextures.contains(key)) {
					var texture:Null<Texture> = currentTrackedAssets["textures"].get(key);
					texture.dispose();
					#if (debug && !mobile)
					trace('limpando $key das texturas');
					#end
					texture = null;
					currentTrackedAssets["textures"].remove(key);
				}

				var graphic:Null<FlxGraphic> = currentTrackedAssets["graphics"].get(key);
				OpenFlAssets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				graphic.destroy();
				currentTrackedAssets["graphics"].remove(key);
			}
		}

		for (key in currentTrackedAssets["sounds"].keys()) {
			if (!localTrackedAssets["sounds"].contains(key)) {
				OpenFlAssets.cache.removeSound(key);
				currentTrackedAssets["sounds"].remove(key);
			}
		}
		if(runG)
			gColetor();
	}

	public static function gColetor()
		{
		// run the garbage collector for good measure lmfao
		#if (cpp || neko || java || hl)
		Gc.run(true);
		Gc.compact();
		#end
		}

	public static function clearStoredMemory():Void
	{
		FlxG.bitmap.dumpCache();

		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			if (!currentTrackedAssets["graphics"].exists(key))
			{
				var graphic:Null<FlxGraphic> = FlxG.bitmap._cache.get(key);
				OpenFlAssets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				graphic.destroy();
			}
		}

		for (key in OpenFlAssets.cache.getSoundKeys())
		{
			if (!currentTrackedAssets["sounds"].exists(key))
				OpenFlAssets.cache.removeSound(key);
		}

		for (key in OpenFlAssets.cache.getFontKeys())
			OpenFlAssets.cache.removeFont(key);

		localTrackedAssets["sounds"] = localTrackedAssets["graphics"] = [];
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

	inline static public function getSparrowAtlas(key:String, ?library:String, ?locale:Bool, usaGPU:Bool = false)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library, locale, usaGPU), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String, ?locale:Bool = false, usaGPU:Bool = false)
	{
		var imageLoaded:FlxGraphic = returnGraphic(key, library, locale, usaGPU);

		return FlxAtlasFrames.fromSpriteSheetPacker((imageLoaded != null ? imageLoaded : image(key, library)), file('images/$key.txt', library));
	}

	public static function returnGraphic(key:String, ?library:String, ?locale:Bool, usarGPU:Bool = false)
	{
		var path:String = getPath('images/$key.png', IMAGE, library);
		if (OpenFlAssets.exists(path))
		{
			if (!currentTrackedAssets["graphics"].exists(path)) //Talvez essa segunda parte não seja usada mas né?
			{
				var graphic:FlxGraphic;
				var bitmapData:BitmapData = OpenFlAssets.getBitmapData(path);

				openfl.display.FPS.curMemChecker();

				if ((SaveData.gpuTextures
				#if (mobile || debug)
					&& openfl.display.FPS.curMEMforReference > limites[SaveData.curPreset] ^ 2
					&& PlayState.isPlayState #end)
					|| currentTrackedAssets["textures"].exists(path) || usarGPU) //Basicamente, se o uso da CPU chegar próximo do limite do aparelho, então a GPU será usada
				{ //É mais fácil gerenciar a GPU através da CPU do que o contrário.
					//Caso o jogo consuma mais do que um celular de 2gb pode aguenta,
					//Ele passa a usar GPU pra segurar o jooj por um pouco mais de tempo antes de precisar reiniciar o APK
					
					if (!currentTrackedAssets["textures"].exists(path)){
					#if (debug && !mobile)
					trace('carregando $path por GPU');
					#end
					var texture:Texture = FlxG.stage.context3D.createTexture(bitmapData.width, bitmapData.height, BGRA, true);
					texture.uploadFromBitmapData(bitmapData);
					currentTrackedAssets["textures"].set(path, texture);

					bitmapData.disposeImage();
					bitmapData.dispose();
					bitmapData = null;
					if(usarGPU)
						noDisposeTextures.push(path);
					}

					graphic = FlxGraphic.fromBitmapData(openfl.display.BitmapData.fromTexture(currentTrackedAssets["textures"].get(path)), false, path);
				}else{
					#if (debug && !mobile)
					trace('carregando $path por CPU');
					#end
					//Checa a cada vez que um asset é carregado pra saber se devemos ou não, ativar a GPU
					graphic = FlxGraphic.fromBitmapData(bitmapData, false, path);
				}

				graphic.persist = true;
				currentTrackedAssets["graphics"].set(path, graphic);
			}

			localTrackedAssets["graphics"].push(path);
			return currentTrackedAssets["graphics"].get(path);
		}
		FlxG.log.error('oh no $path is returning null NOOOO');
		return null; // Apenas para garantir que o jooj tentará carregar do jeito normal primeiro (ou então ajuidar a descobrir qual o pilantra.)
	}

	public static function returnSound(path:String, key:String, ?library:String)
	{
		var file:String = getPath(path == 'songs' ? '$key.$SOUND_EXT' : '$path/$key.$SOUND_EXT', SOUND, path == 'songs' ? path : library);
		#if (debug && !mobile)
		trace('carregando $file'); // Apenas pra eu ter uma noção melhor dos carregamentos desncessauros que esse mod tá fazendo.
		#end
		if (OpenFlAssets.exists(file))
		{
			if (!currentTrackedAssets["sounds"].exists(file))
				currentTrackedAssets["sounds"].set(file, OpenFlAssets.getSound(file));

			localTrackedAssets["sounds"].push(file);
			return currentTrackedAssets["sounds"].get(file);
		}

		FlxG.log.error('oh no $file is returning null NOOOO');
		return null;
	}
}
