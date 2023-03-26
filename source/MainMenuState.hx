package;

import Controls.KeyboardScheme;
import haxe.Json;
import lime.utils.Assets;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup;
import flixel.effects.FlxFlicker;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import flixel.group.FlxGroup.FlxTypedGroup;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end
#if FEATURE_GAMEJOLT
import GameJolt.GameJoltAPI;
#end

using StringTools;

typedef MenuCharacterData = 
{
	var name:String;
	var spritePos:Array<Int>;
	var atlas:String;
	var prefix:String;

	@:optional var scale:Array<Float>;
	@:optional var frames:Int;
	@:optional var looped:Bool;
}

typedef MenuCharacterJSON =
{
	var characters:Array<MenuCharacterData>;
}

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var show:String = "";
	var menuItems:FlxTypedGroup<FlxText>;

	var optionShit:Array<String> = ['story mode', 'freeplay', 'gallery', 'credits', 'options', 'exit'];

	public static var firstStart:Bool = true;

	public var acceptInput:Bool = true;

	var logo:FlxSprite;
	var menu_character:FlxSprite;
	var shaker:FlxSprite;
	var addVally:Bool = false;

	var backdrop:FlxBackdrop;
	var logoBl:FlxSprite;
	public static var menuCharJSON:MenuCharacterJSON;

	public static var instance:MainMenuState;
	var versionShit:FlxText;


	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		instance = this;

		persistentUpdate = persistentDraw = true;

		#if desktop
		FlxG.mouse.visible = true;
		#end

		if(!Assets.exists("assets/doki/characters/monika.chr")) 
		{
			//SOBRE A IDEIA do grf, dá pra usar um firsttime, para fazer um evento específico de abrir um link e etc
			versionShit.text = "APENAS MONIKA, APENAS MONIKA, APENAS MONIKA, A P E N A S M O N I K A, APENAS MONIKA";
		}
		if(!Assets.exists("assets/doki/characters/natsuki.chr"))
		{
			versionShit.text = "END";
		}
		if (!Assets.exists("assets/doki/characters/sayori.chr"))
		{
			versionShit.text = "É por isso que as pontas dos dedos dela estavam todas ensanguentadas, de qualquer maneira.";
		}
		if (!Assets.exists("assets/doki/characters/yuri.chr"))
		{
			versionShit.text = "JUST MONIKA.";
		}
		if (!SaveData.beatPrologue)
		{
			SaveData.weekUnlocked = 1;
			optionShit.remove('freeplay');
		}

		if (!SaveData.beatProtag)
			optionShit.remove('credits');

		if (!SaveData.beatSide)
			optionShit.remove('gallery');

		addVally = true;

		#if FEATURE_DISCORD
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			Conductor.changeBPM(120);
		}

		backdrop = new FlxBackdrop(Paths.image('backdropsmenu/backdropcatfight'));
		backdrop.velocity.set(-40, -40);
		backdrop.antialiasing = SaveData.globalAntialiasing;
		add(backdrop);

		var menuString:String = Assets.getText(Paths.json('menuCharacters'));
		var jsonFound:Bool = true;

		try {
			menuCharJSON = cast Json.parse(menuString);
		} catch (ex) {
			jsonFound = false;
			trace("Couldn't find that file. What a blunder!");
		}

		var twenty:Array<String> = ['together1', 'yuri', 'natsuki', 'sayori', 'pixelmonika', 'senpai'];
		var ten:Array<String> = ['sunnat', 'yuritabi', 'minusmonikapixel', 'yuriken', 'sayominus', 'cyrixstatic', 'zipori', 'nathaachama'];
		var two:Array<String> = ['fumo'];

		// Push certain strings into arrays after save checks here
		if (SaveData.beatFestival)
			twenty.push('protag');

		if (SaveData.beatMonika)
		{
			ten.push('deeppoems');
			ten.push('akimonika');
			ten.push('indiehorror');
		}

		if (SaveData.unlockAntipathyCostume)
			ten.push('nathank');

		if (CoolUtil.flixelSaveCheck('ShadowMario', 'VS Impostor')) // amogus
			ten.push('sayomongus');

		var random:Float = Random.randNF();
		if (random < 0.80) // 80% chance
			show = selectMenuCharacter(twenty);
		else if (random >= 0.80 && random < 0.98) // 18% chance
			show = selectMenuCharacter(ten);
		else // 2% chance 
			show = selectMenuCharacter(two);
		
		if (jsonFound)
		{
			for (char in menuCharJSON.characters)
			{
				if (char.name == show)
				{
					// Found the character in the menuCharacter.json file
					trace('found ${show} with ${random}');
					menu_character = new FlxSprite(char.spritePos[0], char.spritePos[1]);
					menu_character.frames = Paths.getSparrowAtlas(char.atlas);
					if (char.scale != null)
						menu_character.scale.set(char.scale[0], char.scale[1]);
					menu_character.animation.addByPrefix('play', char.prefix, 
						(char.frames != null ? char.frames : 24), (char.looped != null ? char.looped : false));
					// Break the for loop so we can move on from this lol
					break;
				}
			}
		}

		if (menu_character == null)
		{
			// Just gotta use the default together asset if that for-loop doesn't work
			trace("For loop didn't work. Oh well!");
			menu_character = new FlxSprite(490, 50);
			menu_character.frames = Paths.getSparrowAtlas("menucharacters/dokitogetheralt");
			menu_character.scale.set(0.77, 0.77);
			menu_character.animation.addByPrefix('play', "Doki together club", 21, false);
		}
		menu_character.antialiasing = SaveData.globalAntialiasing;
		menu_character.updateHitbox();
		menu_character.animation.play('play');
		add(menu_character);

		logo = new FlxSprite(-260, 0).loadGraphic(Paths.image('Credits_LeftSide'));
		logo.antialiasing = SaveData.globalAntialiasing;
		add(logo);
		if (firstStart)
			FlxTween.tween(logo, {x: -60}, 1.2, {
				ease: FlxEase.elasticOut,
				onComplete: function(flxTween:FlxTween)
				{
					firstStart = false;
					changeItem();
				}
			});
		else
			logo.x = -60;

		logoBl = new FlxSprite(-160, -40);
		logoBl.frames = Paths.getSparrowAtlas('DDLCStart_Screen_Assets');
		logoBl.antialiasing = SaveData.globalAntialiasing;
		logoBl.scale.set(0.5, 0.5);
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		add(logoBl);
		if (firstStart)
			FlxTween.tween(logoBl, {x: 40}, 1.2, {
				ease: FlxEase.elasticOut,
				onComplete: function(flxTween:FlxTween)
				{
					firstStart = false;
					changeItem();
				}
			});
		else
			logoBl.x = 40;

		menuItems = new FlxTypedGroup<FlxText>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxText = new FlxText(-350, 370 + (i * 50), 0, LangUtil.getString(optionShit[i], 'menu'));
			menuItem.setFormat(LangUtil.getFont('riffic'), 27, FlxColor.WHITE, LEFT);
			menuItem.antialiasing = SaveData.globalAntialiasing;
			menuItem.setBorderStyle(OUTLINE, 0xFFFF7CFF, 2);
			menuItem.ID = i;
			menuItems.add(menuItem);

			if (firstStart)
				FlxTween.tween(menuItem, {x: 50}, 1.2 + (i * 0.2), {
					ease: FlxEase.elasticOut,
					onComplete: function(flxTween:FlxTween)
					{
						firstStart = false;
						changeItem();
					}
				});
			else
				menuItem.x = 50;
		}

		shaker = new FlxSprite(1132, 538);
		shaker.frames = Paths.getSparrowAtlas("shaker", 'preload');
		shaker.animation.addByPrefix('play', "Shaker", 21, false);
		shaker.antialiasing = SaveData.globalAntialiasing;
		shaker.animation.play('play');
		if (addVally)
			add(shaker);

		versionShit = new FlxText(-350, FlxG.height - 24, 0, "v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.antialiasing = SaveData.globalAntialiasing;
		versionShit.setFormat(LangUtil.getFont('aller'), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.y += LangUtil.getFontOffset('aller');
		add(versionShit);

		if (firstStart)
			FlxTween.tween(versionShit, {x: 5}, 1.2, {
				ease: FlxEase.elasticOut,
				onComplete: function(flxTween:FlxTween)
				{
					firstStart = false;
					changeItem();
				}
			});
		else
			versionShit.x = 5;

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if (!selectedSomethin && acceptInput)
		{
			if (shaker != null && addVally && BSLTouchUtils.apertasimples(shaker))
				openSong();
			
			if (controls.RESET)
				MusicBeatState.resetState();

			#if debug
			if (FlxG.keys.justPressed.O)
				SaveData.unlockAll();

			if (FlxG.keys.justPressed.P)
				SaveData.unlockAll(false);
			#end

			menuItems.forEach(function(txt:FlxText){
				if(BSLTouchUtils.apertasimples(txt)){
					curSelected=txt.ID;
					changeItem(txt.ID);
					selectThing();
				}
			});

			if (controls.ACCEPT)
				selectThing();
			
			if (controls.BACK #if android || FlxG.android.justReleased.BACK #end)
			    openSubState(new CloseGameSubState()); //Sei lá, acho um detalhe massa
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);
	}

	function goToState()
	{
		var daChoice:String = optionShit[curSelected];

		switch (daChoice)
		{
			case 'story mode':
				MusicBeatState.switchState(new DokiStoryState());
				trace("Story Menu Selected");
			case 'freeplay':
				MusicBeatState.switchState(new DokiFreeplayState());
				trace("Freeplay Menu Selected");
			case 'credits':
				MusicBeatState.switchState(new CreditsState());
				trace("Credits Menu Selected");
			case 'gallery':
				MusicBeatState.switchState(new GalleryArtState());
				trace("La Galeria Selected");
			case 'options':
				MusicBeatState.switchState(new OptionsState());
			case 'exit':
				openSubState(new CloseGameSubState());
		}
	}

	function changeItem(huh:Int = -1)
	{
		menuItems.forEach(function(txt:FlxText)
		{
			if (txt.ID == curSelected)
				txt.setBorderStyle(OUTLINE, 0xFFFFCFFF, 2);
			else
				txt.setBorderStyle(OUTLINE, 0xFFFF7CFF, 2);
		});
	}

	function selectThing():Void
	{
		acceptInput = false;
		selectedSomethin = true;
		FlxG.sound.play(Paths.sound('confirmMenu'));

		menuItems.forEach(function(txt:FlxText)
		{
			if (curSelected != txt.ID)
			{
				FlxTween.tween(txt, {alpha: 0}, 1.3, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						txt.kill();
					}
				});
			}
			else
			{
				if (SaveData.flashing)
				{
					FlxFlicker.flicker(txt, 1, 0.06, false, false, function(flick:FlxFlicker)
					{
						goToState();
					});
				}
				else
				{
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						goToState();
					});
				}
			}
		});
	}

	override function beatHit()
	{
		super.beatHit();

		logoBl.animation.play('bump', true);

		if (!menu_character.animation.curAnim.looped && curBeat % 2 == 0)
			menu_character.animation.play('play', true);

		if (shaker != null)
			shaker.animation.play('play');
	}

	function openSong()
	{
		acceptInput = false;
		selectedSomethin = true;
		FlxG.sound.play(Paths.sound('va11hallaSelect'));
		FlxFlicker.flicker(shaker, 1, 0.06, false, false);

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			PlayState.SONG = Song.loadFromJson('drinks on me', 'drinks on me');
			PlayState.storyDifficulty = 1;
			PlayState.isStoryMode = true;
			MusicBeatState.switchState(new EstadoDeTroca());
		});
	}

	function selectMenuCharacter(array:Array<String>):String
	{
		var index:Int = 0;
		if (array.length >= 2)
			index = Random.randUInt(0, array.length);

		var char:String = '';
		switch (array[index])
		{
			default:
				char = array[index];
			case 'together1':
				if (SaveData.beatMonika)
					char = 'together';
			case 'pixelmonika':
				if (SaveData.beatMonika)
					char = 'monika';
		}

		// Just in case I messed something up
		if (char == '')
		{
			if (SaveData.beatMonika) char = 'together';
			else char = 'together1';
			return char;
		}

		return char;
	}
}
