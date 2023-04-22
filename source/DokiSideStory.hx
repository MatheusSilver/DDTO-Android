package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.effects.FlxFlicker;

class DokiSideStory extends MusicBeatSubstate
{
	public var songData:Array<Array<Dynamic>> = [
		// internal name, song name, posX, posY
		['lovenfunkin', 'Love n Funkin', 305, 64],
		['zipper', 'Constricted', 662, 64],
		['catfight', 'Catfight', 305, 266],
		['wilted', 'Wilted', 662, 266],
		['meta', 'Libitina', 303, 463]
	];

	public static var sidestoryinstance:DokiSideStory;

	public var acceptInput:Bool = false;
	var curSelected:Int = 0;

	var diffSelect:Bool = false;
	var diffText:FlxText;
	var curDifficulty:Int = 1;

	var curSong:String = "";

	var selectGrp:FlxTypedGroup<FlxSprite>;

	public function new()
	{
		super();

		sidestoryinstance = this;

		DokiStoryState.instance.acceptInput = false;

		if (!SaveData.checkAllSongsBeaten() && !SaveData.beatLibitina #if !PUBLIC_BUILD && !FlxG.keys.pressed.F #end)
			songData.pop();

		var background:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFF38CC5);
		background.alpha = 0.4;
		add(background);

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('dokistory/sidestories/sidestoriesmenu'));
		menuBG.antialiasing = SaveData.globalAntialiasing;
		add(menuBG);

		selectGrp = new FlxTypedGroup<FlxSprite>();
		add(selectGrp);

		for (i in 0...songData.length)
		{
			var sideIcon:FlxSprite = new FlxSprite(songData[i][2], songData[i][3]).loadGraphic(Paths.image('dokistory/sidestories/sidestory_' + songData[i][0]));
			sideIcon.antialiasing = SaveData.globalAntialiasing;
			sideIcon.ID = i;
			selectGrp.add(sideIcon);
		}

		new FlxTimer().start(0.1, function(tmr:FlxTimer)
		{
			acceptInput = true;
		});

		addbackButton();

		BSLTouchUtils.prevTouched = -1;

		changeItem();
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (acceptInput)
		{
			#if debug
				if (FlxG.keys.pressed.O)
					SaveData.beatSide = true;
				if (FlxG.keys.pressed.P)
					SaveData.beatSide = false;
			#end
			if (controls.BACK || _backButton.justPressed #if android || FlxG.android.justReleased.BACK #end)
			{
				GlobalSoundManager.play('cancelMenu');
				DokiStoryState.instance.acceptInput = true;
				close();
			}

			if (controls.LEFT_P)
				changeItem(-1);
			if (controls.RIGHT_P)
				changeItem(1);

			if (controls.UP_P)
				changeItem(-2);
			if (controls.DOWN_P)
				changeItem(2);

			selectGrp.forEach(function(spr:FlxSprite)
			{
			if (BSLTouchUtils.aperta(spr,spr.ID) == 'primeiro')
				changeItem(0,spr.ID);
			else if (BSLTouchUtils.aperta(spr, spr.ID) == 'segundo')
				aceitas();
			});

			if (controls.ACCEPT)
			{
				aceitas();
			}
		}
	}

	function aceitas(){
		GlobalSoundManager.play('confirmMenu');
		curDifficulty = 1;
		if (curSong.toLowerCase() == "catfight")
		{
			acceptInput = false;
			openSubState(new CatfightPopup('story'));
		}
		else
		{
			loadSong(curSong);
		}
	}

	function changeItem(amt:Int = 0, trocadireta:Int=-10):Void
	{
		var prevselected:Int = curSelected;
		curSelected += amt;
		if (trocadireta!=-10)
			curSelected = trocadireta;

		if (prevselected != curSelected)
			GlobalSoundManager.play('scrollMenu');

		if (curSelected == 5 && prevselected != 4)
			curSelected = 4;

		if (curSelected >= songData.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = songData.length - 1;

		curSong = songData[curSelected][1];
	}

	public function loadSong(songName:String)
	{
		acceptInput = false;

		var poop:String = Highscore.formatSong(songName, curDifficulty);

		try
		{
			PlayState.SONG = Song.loadFromJson(poop, songName.toLowerCase());
			PlayState.storyDifficulty = curDifficulty;
		}
		catch (e)
		{
			poop = Highscore.formatSong(songName, 1);
			PlayState.SONG = Song.loadFromJson(poop, songName.toLowerCase());
			PlayState.storyDifficulty = 1;
		}

		selectGrp.forEach(function(hueh:FlxSprite)
		{
			if (curSelected == hueh.ID)
				FlxFlicker.flicker(hueh, 1, 0.06, false, false);
		});

		PlayState.isStoryMode = true;
		PlayState.storyPlaylist = [songName.toLowerCase()];
		PlayState.storyWeek = 8;

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			#if mobile
			if (curSong.toLowerCase()=='libitina'){
				MusicBeatState.switchState(new VideoState('assets/videos/metaintro', new EstadoDeTroca()));
				FlxG.sound.music.volume = 0;
			}else #end
				MusicBeatState.switchState(new EstadoDeTroca());
		});
	}
}
