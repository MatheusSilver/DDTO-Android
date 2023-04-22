package;

import flixel.input.keyboard.FlxKey;
import flixel.FlxSubState;
import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import flixel.group.FlxGroup;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end
#if FEATURE_GAMEJOLT
import GameJolt.GameJoltAPI;
#end

using StringTools;

class DokiStoryState extends MusicBeatState
{
	var scoreText:FlxText;

	var weekData:Array<Dynamic> = [
		['High School Conflict', 'Bara No Yume', 'Your Demise', 'Your Reality'],
		['Rain Clouds', 'My Confession'],
		['My Sweets', 'Baka'],
		['Deep Breaths', 'Obsession'],
		['Reconciliation'],
		['Crucify (Yuri Mix)', 'Beathoven (Natsuki Mix)', "It's Complicated (Sayori Mix)", 'Glitcher (Monika Mix)'],
		['Hot Air Balloon', 'Shrinking Violet', 'Joyride', 'Our Harmony'],
		['NEET', 'You and Me', 'Takeover Medley'],
		['Love n\' Funkin\'', 'Constricted', 'Catfight', 'Wilted']
	];

	//Ima make my life easier by being lazy

	var icons:Array<Array<Dynamic>> = [	//internal file name, unlock condition, posX, posY
		['Prologue', true, 394, 199],
		['Sayori', SaveData.beatPrologue, 612, 199],
		['Natsuki', SaveData.beatSayori, 832, 199],
		['Yuri', SaveData.beatNatsuki, 1052, 199],
		['Monika', SaveData.beatYuri, 394, 369],
		['Festival', SaveData.beatMonika, 612, 369],
		['Encore', SaveData.beatFestival, 832, 369],
		['Protag', SaveData.beatEncore, 1052, 369],
		['sideStories', SaveData.beatProtag, 0, 0]
	];

	var grpSprites:FlxSpriteGroup;

	var curDifficulty:Int = 1;

	public static var weekNames:Array<String> = [];

	var txtWeekTitle:FlxText;
	var txtTracklist:FlxText;

	public static var curPos:Int = 0;

	var logo:FlxSprite;
	var songlist:FlxSprite;

	public static var showPopUp:Bool = false;
	public static var popupType:String = 'Prologue';
	var allBeat:Bool = false;

	var story_sidestories:FlxSprite;

	var backdrop:FlxBackdrop;
	var logoBl:FlxSprite;
	var diff:FlxSprite;

	public static var instance:DokiStoryState;


	public var acceptInput:Bool = true;

	override function create()
	{
		allBeat = SaveData.checkAllSongsBeaten();

		FlxG.camera.bgColor = FlxColor.BLACK;

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		instance = this;

		for (i in 1...weekData.length + 1)
			weekNames.push(LangUtil.getString('week$i', 'story'));

		#if FEATURE_DISCORD
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			Conductor.changeBPM(120);
		}

		persistentUpdate = persistentDraw = true;


		backdrop = new FlxBackdrop(Paths.image('backdropsmenu/backdropcatfight'));
		backdrop.velocity.set(-40, -40);
		backdrop.antialiasing = SaveData.globalAntialiasing;
		add(backdrop);

		//-700, -360
		logo = new FlxSprite(-60, 0).loadGraphic(Paths.image('Credits_LeftSide'));
		logo.antialiasing = SaveData.globalAntialiasing;
		add(logo);

		songlist = new FlxSprite(-60, 0).loadGraphic(Paths.image('dokistory/song_list_lazy_smile'));
		songlist.antialiasing = SaveData.globalAntialiasing;
		add(songlist);

		logoBl = new FlxSprite(40, -40);
		logoBl.frames = Paths.getSparrowAtlas('DDLCStart_Screen_Assets', 'preload');
		logoBl.antialiasing = SaveData.globalAntialiasing;
		logoBl.scale.set(0.5, 0.5);
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		add(logoBl);

		txtWeekTitle = new FlxText(FlxG.width * 0.05, 0, 1000, "", 5);
		txtWeekTitle.setFormat(LangUtil.getFont('riffic'), 32, FlxColor.WHITE, FlxTextAlign.CENTER);
		txtWeekTitle.y += LangUtil.getFontOffset('riffic');
		txtWeekTitle.scale.set(1.2, 1.2);
		txtWeekTitle.setBorderStyle(OUTLINE, 0xFFF860B0, 2, 1);
		txtWeekTitle.alignment = FlxTextAlign.CENTER;
		txtWeekTitle.updateHitbox();
		txtWeekTitle.antialiasing = SaveData.globalAntialiasing;
		txtWeekTitle.x = 224;
		txtWeekTitle.y = 150;
		add(txtWeekTitle);

		txtTracklist = new FlxText(FlxG.width * 0.01, 50, 1000, "", 5);
		txtTracklist.setFormat(LangUtil.getFont('riffic'), 32, FlxColor.WHITE, CENTER);
		txtTracklist.y += LangUtil.getFontOffset('riffic');
		txtTracklist.alignment = CENTER;
		txtTracklist.scale.set(.8, .8);
		txtTracklist.setBorderStyle(OUTLINE, 0xFFFFB9DD, 3, 1);
		txtTracklist.updateHitbox();
		txtTracklist.antialiasing = SaveData.globalAntialiasing;
		txtTracklist.x = -230;
		txtTracklist.y = 400;
		add(txtTracklist);

		grpSprites = new FlxSpriteGroup();
		add(grpSprites);

		for (i in 0...icons.length)
		{
			if (i == 8)
				continue;

			var dirstuff:String = 'dokistory/' + icons[i][0] + 'Week';
			var story_icon:FlxSprite = new FlxSprite(icons[i][2], icons[i][3]);
			if (!icons[i][1])
				dirstuff = 'dokistory/LockedWeek';

			story_icon.frames = Paths.getSparrowAtlas(dirstuff, 'preload');
			story_icon.antialiasing = SaveData.globalAntialiasing;
			story_icon.scale.set(0.5, 0.5);
			story_icon.animation.addByPrefix('idle', 'idle', 20);
			story_icon.animation.play('idle');
			story_icon.updateHitbox();
			story_icon.ID = i;
			grpSprites.add(story_icon);

		
		}

		story_sidestories = new FlxSprite(395, 542);
		story_sidestories.frames = Paths.getSparrowAtlas('dokistory/SideStories', 'preload');
		story_sidestories.antialiasing = SaveData.globalAntialiasing;
		story_sidestories.animation.addByPrefix('idle', 'Side Stories0', 20);
		story_sidestories.animation.addByPrefix('selected', 'Side Stories Selected', 20, false);
		story_sidestories.animation.addByPrefix('highlighted', 'Side Stories highlighted', 20);
		story_sidestories.animation.play('idle');
		story_sidestories.ID = 8; // I'm gonna go ahead and force this ID rq
		story_sidestories.visible = false;
		add(story_sidestories);

		changeItem();
		updateText();
		unlockedWeeks();
		updateSelected();

		addbackButton(true);

		BSLTouchUtils.prevTouched = -1;

		super.create();

		_backButton.x = FlxG.width - 50 - _backButton.width;
	}
	
	var selectedSomethin:Bool = false;
	var diffselect:Bool = false;

	override function update(elapsed:Float)
	{
		#if debug
		if (FlxG.keys.pressed.CONTROL && (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L))
		{
			trace('txtTracklist ' + txtTracklist.x + " X " + txtTracklist.y + ' y');
			if (FlxG.keys.pressed.I)
				txtTracklist.y += -10;
			else if (FlxG.keys.pressed.K)
				txtTracklist.y += 10;
			if (FlxG.keys.pressed.J)
				txtTracklist.x += -10;
			else if (FlxG.keys.pressed.L)
				txtTracklist.x += 10;

			trace('txtWeekTitle ' + txtWeekTitle.x + " X " + txtWeekTitle.y + ' y');
			if (FlxG.keys.pressed.I)
				txtWeekTitle.y += -10;
			else if (FlxG.keys.pressed.K)
				txtWeekTitle.y += 10;
			if (FlxG.keys.pressed.J)
				txtWeekTitle.x += -10;
			else if (FlxG.keys.pressed.L)
				txtWeekTitle.x += 10;
		}
		#end

		#if debug
		// popup test
		if (FlxG.keys.justPressed.ONE && acceptInput)
			openSubState(new PopupMessage('prologue'));
		if (FlxG.keys.justPressed.TWO && acceptInput)
			openSubState(new PopupMessage('sayori'));
		if (FlxG.keys.justPressed.THREE && acceptInput)
			openSubState(new PopupMessage('natsuki'));
		if (FlxG.keys.justPressed.FOUR && acceptInput)
			openSubState(new PopupMessage('yuri'));
		if (FlxG.keys.justPressed.FIVE && acceptInput)
			openSubState(new PopupMessage('festival'));
		if (FlxG.keys.justPressed.SIX && acceptInput)
			openSubState(new PopupMessage('encore'));
		if (FlxG.keys.justPressed.SEVEN && acceptInput)
			openSubState(new PopupMessage('protag'));
		if (FlxG.keys.justPressed.EIGHT && acceptInput)
			openSubState(new PopupMessage('side'));
		if (FlxG.keys.justPressed.NINE && acceptInput)
			openSubState(new PopupMessage('libitina'));
		#end

		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if (!selectedSomethin && acceptInput)
		{
			if (showPopUp && !PopupMessage.checkStatus(popupType))
				openSubState(new PopupMessage(popupType));

			if (SaveData.beatYuri && !SaveData.popupYuri)
				openSubState(new PopupMessage('Yuri'));

			if (allBeat && !SaveData.popupLibitina)
				openSubState(new PopupMessage('Libitina'));

			if (controls.LEFT_P)
				changeItem(-1);
			if (controls.RIGHT_P)
				changeItem(1);
			if (controls.UP_P)
				changeItem(-4);
			if (controls.DOWN_P)
				changeItem(4);

			grpSprites.forEach(function(spr:FlxSprite)
			{
				if (BSLTouchUtils.aperta(spr, spr.ID) == 'primeiro')
					changeItem(0, spr.ID);
				else if (BSLTouchUtils.aperta(spr, spr.ID) == 'segundo')
					selectThing();
			});

			if (BSLTouchUtils.aperta(story_sidestories, 8) == 'primeiro')
				changeItem(0, 8);
			else if (BSLTouchUtils.aperta(story_sidestories, 8) == 'segundo')
				selectThing();

			if (controls.BACK || _backButton.justPressed #if android || FlxG.android.justReleased.BACK #end)
			{
				acceptInput = false;
				GlobalSoundManager.play('cancelMenu');
				MusicBeatState.switchState(new MainMenuState());
			}

			if (controls.ACCEPT)
				selectThing();
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);
	}

	function goToState()
	{
		if (FlxG.keys.pressed.E && FlxG.keys.pressed.R && FlxG.keys.pressed.B)
		{
			PlayState.storyPlaylist = ['erb'];
			PlayState.storyDifficulty = 1;
		}
		else
		{
			PlayState.storyPlaylist = weekData[curPos];
			PlayState.storyDifficulty = curDifficulty;
		}

		PlayState.ForceDisableDialogue = false;
		PlayState.isStoryMode = true;
		selectedSomethin = true;
		diffselect = false;

		var poop:String = Highscore.formatSong(PlayState.storyPlaylist[0], PlayState.storyDifficulty);

		switch (curPos)
		{
			case 8:
				story_sidestories.y = 513;
				story_sidestories.animation.play('selected');
			default:
				grpSprites.forEach(function(hueh:FlxSprite)
				{
					if (curPos == hueh.ID)
						FlxFlicker.flicker(hueh, 1, 0.06, false, false);
				});
		}

		try
		{
			PlayState.SONG = Song.loadFromJson(poop, PlayState.storyPlaylist[0].toLowerCase());
		}
		catch (e)
		{
			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase(), PlayState.storyPlaylist[0].toLowerCase());
		}

		PlayState.storyWeek = curPos;
		PlayState.campaignScore = 0;
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			switch (curPos)
			{
				default:
					MusicBeatState.switchState(new EstadoDeTroca());
				#if mobile
				case 1:
					MusicBeatState.switchState(new VideoState('assets/videos/sayointro', new EstadoDeTroca()));
					FlxG.sound.music.volume = 0;
					trace("Sayori Selected");
				#end
				case 6:
					MusicBeatState.switchState(new EstadoDeTroca());
					trace("hueh Week Selected");
			}
		});
	}

	// Totaly not gonna break the code
	// Trust me
	// :) ~Codexes
	override public function openSubState(subState:FlxSubState)
	{
		super.openSubState(subState);
	}

	override public function closeSubState()
	{
		super.closeSubState();
	}
	
	function selectThing()
	{
		if (curPos == 8 && icons[curPos][1])
		{
			GlobalSoundManager.play('confirmMenu');
			openSubState(new DokiSideStory());
		}
		else if (icons[curPos][1])
		{
			selectedSomethin = true;
			GlobalSoundManager.play('confirmMenu');
			goToState();
		}
	}

	function changeItem(huh:Int = 0, trocadireta:Int = -10)
	{
		var prevselected:Int = curPos;
		curPos += huh;

		if (trocadireta != -10)
			curPos = trocadireta;

		if (prevselected != curPos)
			GlobalSoundManager.play('scrollMenu');

		//Tenho minhas dúvidas se esse code é util agora que tudo é por touch...
		if (!SaveData.beatFestival)
		{
			if (curPos >= icons.length)
				curPos = 0;
			if (curPos < 0)
				curPos = icons.length - 1;

			if (curPos == 8)//Just incase this code breaks
				curPos = 0;
		}
		else
		{
			// attempts to loop back into the bottom row
			if (curPos == -4)
				curPos = 8;
			if (curPos == -3)
				curPos = 8;
			if (curPos == -2)
				curPos = 8;
			if (curPos == -1)
				curPos = 8;

			// attempts to loop back into the top row
			if (curPos == 9)
				curPos = 8;
			if (curPos == 10)
				curPos = 8;
			if (curPos == 11)
				curPos = 8;

			if (curPos >= 12)
				curPos = 0;
			if (curPos < 0)
				curPos = 12 - 1;
		}

		updateText();
		updateSelected();

		switch (curPos)
		{
			case 5:
				txtWeekTitle.visible = SaveData.beatMonika;
				txtTracklist.visible = SaveData.beatFestival;
			case 6:
				txtWeekTitle.visible = SaveData.beatFestival;
				txtTracklist.visible = SaveData.beatEncore;
			case 7:
				txtWeekTitle.visible = SaveData.beatEncore;
				txtTracklist.visible = SaveData.beatProtag;
			case 9:
				txtWeekTitle.visible = false;
				txtTracklist.visible = false;
			default:
				trace(icons[curPos][1]);
				txtWeekTitle.visible = icons[curPos][1];
				txtTracklist.visible = icons[curPos][1];
		}
		
	}

	function updateSelected()
	{
		for (icon in grpSprites.members)
		{
			if (icon.ID == curPos)
			{
				icon.animation.play('idle');
				continue;
			}

			icon.animation.stop();
			icon.animation.frameIndex = -1;
		}

		if (curPos != 8 && story_sidestories != null)
		{
			story_sidestories.animation.play('idle');
			story_sidestories.animation.stop();
		}
		else if(curPos == 8 && story_sidestories != null)
		{
			story_sidestories.animation.play('highlighted');
		}
	}

	function unlockedWeeks()
	{
		if (SaveData.beatPrologue)
		{
			SaveData.weekUnlocked = 2;
		}
		if (SaveData.beatSayori)
		{
			SaveData.weekUnlocked = 3;
		}
		if (SaveData.beatNatsuki)
		{
			SaveData.weekUnlocked = 4;
		}
		if (SaveData.beatYuri)
		{
			SaveData.weekUnlocked = 5;
		}
		if (SaveData.beatMonika)
		{
			SaveData.weekUnlocked = 6;
		}
		if (SaveData.beatFestival)
		{
			SaveData.unlockedEpiphany = true;
			SaveData.weekUnlocked = 7;
		}
		if (SaveData.beatEncore)
		{
			SaveData.weekUnlocked = 8;
		}
		if (SaveData.beatProtag)
		{
			story_sidestories.visible = true;
			SaveData.weekUnlocked = 9;
		}
		if (SaveData.beatSide)
		{
			SaveData.weekUnlocked = 10;
		}
		// are we doin one for side stories too?
		// kinda
	}

	function updateText()
	{
		txtTracklist.text = "\n";
		var stringThing:Array<String> = weekData[curPos];

		for (i in stringThing)
		{
			if (i.toLowerCase() == "takeover medley")
				continue;

			if (i.toLowerCase() == "your reality" && !SaveData.beatPrologue)
				continue;

			txtTracklist.text += "\n" + i.split(" (")[0];
		}

		txtWeekTitle.text = weekNames[curPos].toUpperCase();
		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.text += "\n";
	}

	override function beatHit()
	{
		super.beatHit();
		logoBl.animation.play('bump', true);
	}
}

