package;

import Song.SwagSong;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.effects.FlxFlicker;
import flixel.addons.transition.FlxTransitionableState;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end

using StringTools;

class DokiFreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];
	var menu_character:FlxSprite;
	var selector:FlxText;

	public static var instance:DokiFreeplayState;
	public var acceptInput:Bool = true;

	public static var showPopUp:Bool = false;
	public static var popupType:String = '';
	var allBeat:Bool = false;

	var acceptDiferenciado:Bool = false;
	static var curSelected:Int = 0;
	static var curPage:Int = 0;
	static var pageFlipped:Bool = false;

	var curDifficulty:Int = 1;
	var diffType:Int = 0;
	var diffselect:Bool = false;
	var diff:FlxSprite;
	var diffsuffix:String = '';
	var scoreText:FlxText;
	var lerpScore:Float = 0;
	var intendedScore:Float = 0;

	var bg:FlxSprite;
	
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var pageNum:FlxText;
	
	var songPlayback:FlxSprite;
	var modifierMenu:FlxSprite;
	var costumeSelect:FlxSprite;

	private var grpSongs:FlxTypedGroup<FlxText>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	public static var songData:Map<String, Array<SwagSong>> = [];

	public static var singleDiff:Array<String> = [ //Change to multiple difficulties
		'your reality',
		'you and me',
		'takeover medley',
		'libitina',
		'erb'
	];

	public static var multiDiff:Array<String> = [
	'epiphany', 'baka', 'shrinking violet', 'love n funkin'
	];

	public static function loadDiff(diff:Int, name:String, array:Array<SwagSong>)
	{
		try
		{
			array.push(Song.loadFromJson(Highscore.formatSong(name, diff), name));
		}
		catch (ex)
		{
		}
	}

	override function create()
	{
		allBeat = SaveData.checkAllSongsBeaten();

		FlxG.camera.bgColor = FlxColor.BLACK;

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		instance = this;

		if (!FlxG.sound.music.playing && !SaveData.cacheSong)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			Conductor.changeBPM(120);
		}

		if (pageFlipped)
			FlxG.sound.play(Paths.sound('flip_page', 'preload'));

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('data/freeplay/Page' + (curPage + 1)));

		for (i in 0...initSonglist.length)
		{
			var data:Array<String> = initSonglist[i].split(':');
			var meta = new SongMetadata(data[0], Std.parseInt(data[2]), data[1]);

			if (meta.songName.toLowerCase() == 'drinks on me' && !SaveData.beatVA11HallA)
				continue;

			var diffs = [];
			loadDiff(0, meta.songName, diffs);
			loadDiff(1, meta.songName, diffs);
			loadDiff(2, meta.songName, diffs);
			songData.set(meta.songName, diffs);

			if ((Std.parseInt(data[2]) <= SaveData.weekUnlocked - 1) || (Std.parseInt(data[2]) == 1))
				songs.push(meta);
		}

		#if FEATURE_DISCORD
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Freeplay Menu", null);
		#end

		persistentUpdate = persistentDraw = true;

		bg = new FlxSprite().loadGraphic(Paths.image('freeplay/freeplaybook' + (curPage + 1)));
		bg.antialiasing = SaveData.globalAntialiasing;
		add(bg);

		for (i in 0...songs.length)
		{
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter, false, false);
			iconArray.push(icon);
			icon.x = 1060;
			icon.y = 550;
			icon.scale.set(1.6, 1.6);
			icon.angle = 30;

			if ((curPage == 1 && !SaveData.beatEncore)
				|| (curPage == 3 && !SaveData.beatEpiphany)
				|| curPage == 4)
			{
			}
			else
			{
				add(icon);
			}
		}

		grpSongs = new FlxTypedGroup<FlxText>();

		if (curPage == 1 && !SaveData.beatEncore)
		{
		}
		else
		{
			add(grpSongs);
		}

		scoreText = new FlxText(442, 56, 0, "", 8);
		scoreText.setFormat(LangUtil.getFont('halogen'), 29, FlxColor.BLACK, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
		scoreText.y += LangUtil.getFontOffset('halogen');
		scoreText.antialiasing = SaveData.globalAntialiasing;
		add(scoreText);

		if (curPage == 4)
		{
			scoreText.x = 360;
			scoreText.setFormat(LangUtil.getFont('grotesk'), 29, 0xFF821F8E, LEFT);
			scoreText.y += LangUtil.getFontOffset('grotesk') - 10;
		}

		menu_character = new FlxSprite(40, 490);
		if (curPage != 3)
		{			
			menu_character.frames = Paths.getSparrowAtlas('freeplay/chibidorks');
			menu_character.animation.addByPrefix('idle', 'FreeplayChibiIdle', 24, false);
			menu_character.animation.addByPrefix('pop_off', 'FreeplayChibiCheer', 24, false);
		}
		else
		{
			menu_character.x += 40;
			menu_character.frames = Paths.getSparrowAtlas('freeplay/moni');
			menu_character.animation.addByPrefix('idle', 'FreeplayChibiEpiphanyIdle', 24, false);
			menu_character.animation.addByPrefix('pop_off', 'FreeplayChibiEpiphanyCheer', 24, false);
		}
		menu_character.antialiasing = SaveData.globalAntialiasing;
		menu_character.scale.set(1.1, 1.1);
		menu_character.updateHitbox();
		menu_character.animation.play('idle');

		if (curPage != 4)
			add(menu_character);

		diff = new FlxSprite(453, 580);
		diff.frames = Paths.getSparrowAtlas('dokistory/difficulties');
		diff.antialiasing = SaveData.globalAntialiasing;
		diff.animation.addByPrefix('regular', 'Regular', 24);
		diff.animation.addByPrefix('lyrics', 'Lyrics', 24);
		diff.animation.addByPrefix('alt', 'Alt', 24);
		diff.updateHitbox();
		diff.visible = false;
		add(diff);

		for (i in 0...songs.length)
		{
			var metadata:Song.SwagMetadata = null;
			var songName = songs[i].songName;

			try
			{
				metadata = cast haxe.Json.parse(Assets.getText(Paths.json('songs/${songs[i].songName.toLowerCase()}/meta')));
				songName = metadata.song.name;
			}
			catch (e)
			{
				trace('[${songs[i].songName}] Metadata either doesn\'t exist or contains an error!');
				songName = songs[i].songName;
			}

			var songText:FlxText = new FlxText(442, 116 + (i * 47.5), 500, songName, 9);
			songText.setFormat(Paths.font("Halogen.otf"), 29, FlxColor.BLACK, FlxTextAlign.LEFT);
			songText.antialiasing = SaveData.globalAntialiasing;
			songText.borderStyle = OUTLINE;
			songText.borderColor = 0xFFFF7FEE;
			songText.ID = i;
			grpSongs.add(songText);

			if (curPage == 3)
			{
				songText.x = 588;
				songText.y = 395;
			}
			else if (curPage == 4)
			{
				songText.x = 588;
				songText.y = 360;
			}
		}

		if (curPage == 1 && !SaveData.beatEncore)
		{
		}
		else
		{
			changeItem(0);
			changeDiff(0);
		}

		#if debug
		trace(curPage + " hewwo");
		#end

		songPlayback = new FlxSprite(0, 0).loadGraphic(Paths.image('freeplay/extra/preview', 'preload'));
		songPlayback.setGraphicSize(Std.int(songPlayback.width * 0.6));
		songPlayback.updateHitbox();
		songPlayback.x = (FlxG.width - songPlayback.width) - 10;
		songPlayback.y += 10;
		songPlayback.antialiasing = SaveData.globalAntialiasing;
		add(songPlayback);

		modifierMenu = new FlxSprite(0, 0).loadGraphic(Paths.image('freeplay/extra/modifiers', 'preload'));
		modifierMenu.setGraphicSize(Std.int(modifierMenu.width * 0.6));
		modifierMenu.updateHitbox();
		modifierMenu.x = (FlxG.width - modifierMenu.width) - 10;
		modifierMenu.y += modifierMenu.height + 10;
		modifierMenu.antialiasing = SaveData.globalAntialiasing;
		add(modifierMenu);

		if (SaveData.cacheSong)
			modifierMenu.y -= modifierMenu.height;

		costumeSelect = new FlxSprite(0, 0).loadGraphic(Paths.image('freeplay/extra/costume', 'preload'));
		costumeSelect.setGraphicSize(Std.int(costumeSelect.width * 0.6));
		costumeSelect.updateHitbox();
		costumeSelect.x = (FlxG.width - costumeSelect.width) - 10;
		costumeSelect.y += modifierMenu.y + modifierMenu.height + 10;
		costumeSelect.antialiasing = SaveData.globalAntialiasing;
		if (SaveData.beatProtag && (curPage != 3 && curPage != 4))
			add(costumeSelect);
		//Novamente fazendo coisas sem testar e sem ver os assets.
		//Então é melhor lembrar de no final, trocar a skin do custom controls pela padrão usada na galeria.
	
		pageNum = new FlxText(580, 580, 0, 'Página ' + Std.string(curPage + 1), 48);
		pageNum.setFormat(LangUtil.getFont('riffic'), 48, FlxColor.WHITE, FlxTextAlign.CENTER);
		pageNum.y += LangUtil.getFontOffset('riffic');
		pageNum.setBorderStyle(OUTLINE, 0xFFF860B0, 2, 1);
		pageNum.text = 'Página ' + Std.string(curPage + 1);
		pageNum.alignment = FlxTextAlign.CENTER;
		pageNum.updateHitbox();
		pageNum.antialiasing = SaveData.globalAntialiasing;
		//Lembrar de trocar a fonte aqui depois (É só copiar e colar o code do menu principal com alteração no size da fonte)
		add(pageNum);

		if (curPage == 4){ //Maldita libitina...
			pageNum.screenCenter(X);
			pageNum.y -= 30;
		}
		
		leftArrow = new FlxSprite(pageNum.x - 60,pageNum.y - 10);
		leftArrow.loadGraphic(Paths.image('seta', 'doki'));
		leftArrow.antialiasing = SaveData.globalAntialiasing;
		leftArrow.updateHitbox();

		rightArrow = new FlxSprite(pageNum.x + 205, leftArrow.y);
		rightArrow.loadGraphic(Paths.image('seta', 'doki'));
		rightArrow.flipX=true;
		rightArrow.antialiasing = SaveData.globalAntialiasing;
		rightArrow.updateHitbox();
	
		
		add(leftArrow);
		add(rightArrow);

		addbackButton(true);

		diffselect = false;

		BSLTouchUtils.prevTouched = -1; //Só pra garantir k

		super.create();
		
		_backButton.x = modifierMenu.x + (modifierMenu.width - _backButton.width)/2 + 5;
		
		if (SaveData.beatProtag && (curPage != 3 && curPage != 4))
			_backButton.y = costumeSelect.y + costumeSelect.height + 10;	
		else
			_backButton.y = modifierMenu.y + modifierMenu.height + 10;
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		lerpScore = Math.abs(FramerateTools.lerpConvert(lerpScore, intendedScore, 0.4));

		scoreText.text = LangUtil.getString('cmnPB') + ': ' + Math.round(lerpScore);

		if (FlxG.sound.music != null && FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		#if debug
		if (FlxG.keys.justPressed.F1 && acceptInput)
			openSubState(new PopupMessage('epiphany', 'freeplay'));
		if (FlxG.keys.justPressed.F3 && acceptInput)
			openSubState(new PopupMessage('libitina', 'freeplay'));
		#end

		if (!selectedSomethin && acceptInput)
		{
			if (showPopUp)
				openSubState(new PopupMessage(popupType, 'freeplay'));

			if (allBeat && !SaveData.popupLibitina)
				openSubState(new PopupMessage('Libitina', 'freeplay'));

			grpSongs.forEach(function(spr:FlxText)
			{
				if (BSLTouchUtils.aperta(spr, spr.ID) == 'primeiro')
					changeItem(spr.ID);
				else if (BSLTouchUtils.aperta(spr, spr.ID) == 'segundo')
					acceptDiferenciado = true;
			});

			if (BSLTouchUtils.apertasimples(diff))
				changeDiff(1);

			if (BSLTouchUtils.apertasimples(modifierMenu))
			{
				GlobalSoundManager.play('confirmMenu');
				openSubState(new DokiModifierSubState());
			}

			if (SaveData.beatProtag && BSLTouchUtils.apertasimples(costumeSelect) && (curPage != 3 && curPage != 4))
				MusicBeatState.switchState(new CostumeSelectState());
			//Mim == bulo
			if (controls.UP_P && !diffselect && (curPage != 3 && curPage != 4))
			{
				if ((curPage == 1 && !SaveData.beatEncore) || (curPage == 2 && !SaveData.beatPrologue))
				{
				}
				else
				{
					GlobalSoundManager.play('scrollMenu');
					changeItem(-1);
				}
			}

			if (controls.DOWN_P && !diffselect && (curPage != 3 && curPage != 4))
			{
				if ((curPage == 1 && !SaveData.beatEncore) || (curPage == 2 && !SaveData.beatPrologue))
				{
				}
				else
				{
					GlobalSoundManager.play('scrollMenu');
					changeItem(1);
				}
			}

			if (FlxG.keys.justPressed.ONE)
				changePageHotkey(0);

			if (FlxG.keys.justPressed.TWO)
				changePageHotkey(1);

			if (FlxG.keys.justPressed.THREE)
				changePageHotkey(2);

			if (FlxG.keys.justPressed.FOUR && SaveData.unlockedEpiphany)
				changePageHotkey(3);

			if (FlxG.keys.justPressed.FIVE && SaveData.beatLibitina)
				changePageHotkey(4);

			if ((controls.LEFT_P || BSLTouchUtils.apertasimples(leftArrow)) && !diffselect)
				changePageHotkey(-1, false);
			
			if ((controls.RIGHT_P || BSLTouchUtils.apertasimples(rightArrow))&& !diffselect)
				changePageHotkey(1, false);

			//Eu amo a Monka, mas as vezes ela é chatona man...

			if (controls.BACK || _backButton.justPressed #if android || FlxG.android.justReleased.BACK #end)
			{
				switch (diffselect)
				{
					case true:
						diff.visible = false;
						diffselect = false;
						diffsuffix = '';
						pageNum.visible = true;
						rightArrow.visible=true;
						leftArrow.visible=true;
					case false:
						selectedSomethin = true;
						pageFlipped = false;
						curSelected = 0;
						curPage = 0;
						GlobalSoundManager.play('cancelMenu');
						MusicBeatState.switchState(new MainMenuState());
				}
			}

			// Something barebones to hold off from playing the song
			// until you hit spacebar
			// Barebones because it's something quick that I could think of before doing other things
			if (FlxG.keys.justPressed.SPACE || BSLTouchUtils.apertasimples(songPlayback) && !selectedSomethin && !SaveData.cacheSong)
				playSong();

			if (controls.LEFT_P && diffselect)
			{
				GlobalSoundManager.play('scrollMenu');
				changeDiff(-1);
			}

			if (controls.RIGHT_P && diffselect)
			{
				GlobalSoundManager.play('scrollMenu');
				changeDiff(1);
			}

			if (FlxG.keys.justPressed.F7 && SaveData.unlockedEpiphany)
				loadSong(true);

			if ((controls.ACCEPT || acceptDiferenciado)  && songs.length >= 1)
			{
				acceptDiferenciado = false;
				selectSong();
			}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
	
		super.update(elapsed);
	}
	
	}

	public function startsong()
	{
		pageFlipped = false;
		selectedSomethin = true;
		GlobalSoundManager.play('confirmMenu');
		menu_character.y -= 31;
		menu_character.animation.play('pop_off');
		grpSongs.forEach(function(spr:FlxSprite)
		{
			if (curSelected != spr.ID)
			{
				FlxTween.tween(spr, {alpha: 0}, 1.3, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						spr.kill();
					}
				});
			}
			else
			{
				if (SaveData.flashing)
				{
					FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
					{
						loadSong();
					});
				}
				else
				{
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						loadSong();
					});
				}
			}
		});
	}

		function selectSong()
		{
			if (diffselect && multiDiff.contains(songs[curSelected].songName.toLowerCase()) && SaveData.beatEpiphany)
			{
				if (diffType == 1)
					curDifficulty = 1;

				startsong();
				return;
			}

			if (multiDiff.contains(songs[curSelected].songName.toLowerCase()))
			{
				switch (songs[curSelected].songName.toLowerCase())
				{
					case 'epiphany':
						GlobalSoundManager.play('confirmMenu');
						diffType = 0;
						diff.visible = true;
						diffselect = true;
					case 'baka' | 'shrinking violet' | 'love n funkin':
						GlobalSoundManager.play('confirmMenu');
						diffType = 1;
						diff.visible = true;
						diffselect = true;
					default:
						startsong();
				}
			}
			else
			{
				curDifficulty = 1;
				if (songs[curSelected].songName.toLowerCase() == 'catfight')
					openSubState(new CatfightPopup('freeplay'));
				else
					startsong();
		}
	}

	function loadSong(isCharting:Bool = false)
	{
		var poop:String = Highscore.formatSong(songs[curSelected].songName + diffsuffix, curDifficulty);

		PlayState.isStoryMode = false;

		try
		{
			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase() + diffsuffix);
			PlayState.storyDifficulty = curDifficulty;
		}
		catch (e)
		{
			poop = Highscore.formatSong(songs[curSelected].songName, 1);
			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase() + diffsuffix);
			PlayState.storyDifficulty = 1;
		}

		PlayState.storyWeek = songs[curSelected].week;

		if (FlxG.keys.pressed.E && FlxG.keys.pressed.R && FlxG.keys.pressed.B)
			PlayState.SONG = Song.loadFromJson('erb', 'erb');

		if (FlxG.keys.pressed.P)
			PlayState.practiceMode = true;

		// force disable dialogue
		if (FlxG.keys.pressed.F)
			PlayState.ForceDisableDialogue = true;

		if (isCharting)
			LoadingState.loadAndSwitchState(new ChartingState());
		else
			MusicBeatState.switchState(new EstadoDeTroca());
	}

	function changeDiff(change:Int = 0):Void
	{
		diffsuffix = '';
		curDifficulty += change;

		if (curDifficulty <= 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 1;

		switch (curDifficulty)
		{
			case 2:
				trace('hard');
				diff.animation.play((diffType == 0 ? 'lyrics' : 'alt'));
				if (diffType == 1)
					diffsuffix = '-alt';
			case 1:
				trace('normal');
				diff.animation.play('regular');
		}

		getSongData(songs[curSelected].songName + diffsuffix, curDifficulty);
	}

	function playSong()
	{
		FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), SaveData.cacheSong ? 0 : 1);

		var hmm;
		try
		{
			hmm = songData.get(songs[curSelected].songName)[0]; // curDifficulty
			if (hmm != null)
				Conductor.changeBPM(hmm.bpm);
		}
		catch (ex)
		{
			Conductor.changeBPM(102);
		}
	}

	function changeItem(change:Int = 6)
	{
		curSelected = change;

		if ((curPage == 1 && !SaveData.beatEncore) || (curPage == 2 && !SaveData.beatPrologue))
		{
			trace('look at me I am not beaten');
		}
		else
		{
			getSongData(songs[curSelected].songName + diffsuffix, curDifficulty);


			if (SaveData.cacheSong)
			{
				if (FlxG.sound.music != null)
				{
					FlxG.sound.music.stop();
					FlxG.sound.music.destroy();
					FlxG.sound.music = null;
				}
	
				playSong();
			}
		}

		if ((curPage == 1 && !SaveData.beatEncore) || (curPage == 2 && !SaveData.beatPrologue))
		{
		}
		else
		{
			for (i in 0...iconArray.length)
			{
				iconArray[i].alpha = 0;
			}

			if (iconArray.length > 0)
				iconArray[curSelected].alpha = 1;
		}

		for (item in grpSongs.members)
		{
			if (item.ID != curSelected)
				item.setBorderStyle(OUTLINE, 0x00FF7FEE, 1, 1);
			else
				item.setBorderStyle(OUTLINE, 0xFFFF7FEE, 1, 1);
		}
	}

	function getSongData(songName:String, diff:Int)
	{
		if (!multiDiff.contains(songName.toLowerCase()))
			diff = 1;

		intendedScore = Highscore.getScore(songName + diffsuffix, diff);
	}

	function changePage(huh:Int = 0)
	{
		pageFlipped = true;
		curSelected = 0;
		curPage += huh;
		if (!SaveData.unlockedEpiphany)
		{
			if (curPage >= 3)
				curPage = 0;
			if (curPage < 0)
				curPage = 3 - 1;
		}
		else if (!SaveData.beatLibitina)
		{
			if (curPage >= 4)
				curPage = 0;
			if (curPage < 0)
				curPage = 4 - 1;
		}
		else
		{
			if (curPage >= 5)
				curPage = 0;
			if (curPage < 0)
				curPage = 5 - 1;
		}
		// updating page stuff here
	}
	
	function changePageHotkey(page:Int, directPage:Bool = true)
	{
		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		if (directPage)
		{
			pageFlipped = true;
			curSelected = 0;
			curPage = page;
		}
		else
			changePage(page);

		MusicBeatState.switchState(new DokiFreeplayState());
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}
