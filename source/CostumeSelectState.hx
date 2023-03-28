package;

import Controls.KeyboardScheme;
import haxe.Json;
import lime.utils.Assets;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;

using StringTools;

typedef CostumeData =
{
	var data:String;
	var name:String;
	var desc:String;
	var color:String;
	@:optional var unlock:String;
}

typedef CostumeCharacter =
{
	var id:String;
	var charName:String;
	var costumes:Array<CostumeData>;
}

typedef CostumeJSON =
{
	var list:Array<CostumeCharacter>;
}

class CostumeSelectState extends MusicBeatState
{
	var curSelected:Int = 0;
	var costumeSelected:Int = 0;
	var hueh:Int = 0;
	var chara:FlxSprite;
	private var grpControls:FlxTypedGroup<FlxText>;
	private var grpControlshueh:FlxTypedGroup<FlxText>;
	var selectingcostume:Bool = false;
	var logo:FlxSprite;

	var flavorBar:FlxSprite;
	var backdrop:FlxBackdrop;
	var logoBl:FlxSprite;
	var costumeLabel:FlxText;
	var controlLabel:FlxText;
	var flavorText:FlxText;

	var character:Array<String> = ['bf', 'gf', 'monika', 'sayori', 'natsuki', 'yuri', 'protag'];
	// costume unlocks
	var costumeUnlocked:Array<Dynamic> = [
		// Boyfriend
		[
		true, true, true, true, true, true, true
		],
		// Girlfriend
		[
		true, true, true, true, true, true, true
		],
		// Monika
		[
		true, true, true, true, true, true, true
		],
		// Sayori
		[
			true,
			true,
			true,
			true,
			true,
			true, 
			true
		],
		// Natsuki
		[
		true, true, true, true, true, true, true
		],
		// Yuri
		[
		true, true, true, true, true, true, true
		],
		// Protag
		[
			true, // Uniform, unlocked by default
			true, // Casual, unlocked by default
			true,
			true
		]
	];
	var costumeJSON:CostumeJSON = null;

	override function create()
	{
		Character.ingame = false;

		
		FlxG.sound.playMusic(Paths.music('disco'), 0.4);
		Conductor.changeBPM(124);

		persistentUpdate = persistentDraw = true;

		var costumestring:String = Assets.getText(Paths.json('costumeData'));

		try {
			costumeJSON = cast Json.parse(costumestring);
		} catch (ex) {
			trace("Costume JSON cannot be found. \n" + costumestring);
		}

		backdrop = new FlxBackdrop(Paths.image('backdropsmenu/backdropcatfight'));
		backdrop.velocity.set(-40, -40);
		backdrop.antialiasing = SaveData.globalAntialiasing;
		add(backdrop);

		chara = new FlxSprite(522, 9).loadGraphic(Paths.image('costume/bf', 'preload'));
		chara.antialiasing = SaveData.globalAntialiasing;
		chara.scale.set(0.7, 0.7);
		chara.updateHitbox();
		add(chara);

		flavorBar = new FlxSprite(0, 605).makeGraphic(1280, 63, 0xFFFF8ED0);
		flavorBar.alpha = 0.4;
		flavorBar.screenCenter(X);
		flavorBar.scrollFactor.set();
		flavorBar.visible = false;
		add(flavorBar);

		flavorText = new FlxText(354, 608, 933, "I'm a test, this is for scale!", 40);
		flavorText.scrollFactor.set(0, 0);
		flavorText.setFormat(LangUtil.getFont('riffic'), 20, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		flavorText.y += LangUtil.getFontOffset();
		flavorText.borderSize = 2;
		flavorText.borderQuality = 1;
		flavorText.antialiasing = SaveData.globalAntialiasing;
		flavorText.visible = false;
		add(flavorText);

		logo = new FlxSprite(-60, 0).loadGraphic(Paths.image('Credits_LeftSide'));
		logo.antialiasing = SaveData.globalAntialiasing;
		add(logo);

		logoBl = new FlxSprite(40, -40);
		logoBl.frames = Paths.getSparrowAtlas('DDLCStart_Screen_Assets');
		logoBl.antialiasing = SaveData.globalAntialiasing;
		logoBl.scale.set(0.5, 0.5);
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		add(logoBl);

		grpControls = new FlxTypedGroup<FlxText>();
		add(grpControls);

		for (i in 0...costumeJSON.list.length)
		{
			var id:String = LangUtil.getString(costumeJSON.list[i].charName, 'costume');

			controlLabel = new FlxText(60, (40 * i) + 370, 0, id, 3);
			controlLabel.setFormat(LangUtil.getFont('riffic'), 38, FlxColor.WHITE, CENTER);
			controlLabel.y += LangUtil.getFontOffset('riffic');
			controlLabel.scale.set(0.7, 0.7);
			controlLabel.updateHitbox();
			controlLabel.setBorderStyle(OUTLINE, 0xFFFF7CFF, 2);
			controlLabel.antialiasing = SaveData.globalAntialiasing;
			controlLabel.ID = i;
			grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);
			
		if (!selectedSomethin)
		{
			if (controls.UP_P && !selectingcostume)
			{
				changeItem(-1);
			}
			
			if (!selectingcostume){
				grpControls.forEach(function(txt:FlxText)
				{
					if (BSLTouchUtils.aperta(txt, txt.ID)=='primeiro')
						changeItemDirectly(txt.ID);
					else if (BSLTouchUtils.aperta(txt, txt.ID) == 'segundo')
						costumeselect(true);
				});
			}else{
				grpControlshueh.forEach(function(txt:FlxText)
				{
					if (BSLTouchUtils.aperta(txt, txt.ID) == 'primeiro')
						changeCostumeDirectly(txt.ID);
					else if (BSLTouchUtils.aperta(txt, txt.ID) == 'segundo')
						savecostume();
				});
			}

			if (controls.DOWN_P && !selectingcostume)
			{
				changeItem(1);
			}

			if (controls.DOWN_P && selectingcostume)
			{
				changecostume(1, true);
			}

			if (controls.UP_P && selectingcostume)
			{
				changecostume(-1, false);
			}
			if ((controls.BACK #if android || FlxG.android.justReleased.BACK #end) && !selectingcostume)
			{
				selectedSomethin = true;
				SaveData.save();
				FlxG.sound.music.stop();
				GlobalSoundManager.play('cancelMenu');
				MusicBeatState.switchState(new DokiFreeplayState());
			}
			if ((controls.BACK #if android || FlxG.android.justReleased.BACK #end) && selectingcostume)
			{
				GlobalSoundManager.play('cancelMenu');
				costumeselect(false);
				
				// Initial bug is that, if you have a selected character, but
				// try to select a locked character, and then hit ESC, the
				// selected character is rendered black
				// This fix should hopefully resolve it.

				if (chara.color == 0x000000)
					chara.color = 0xFFFFFF;
			}
			if (controls.ACCEPT)
				if (!selectingcostume)
					costumeselect(true);
				else
					savecostume();
		}
	}

	function loadcharacter(char:String, ?costume:String, ?forceColor:FlxColor = 0xFFFDDBF1)
	{
		var charCostume:String = costume;
		if (charCostume == '' || charCostume == null)
		{
			switch (char)
			{
				case 'protag':
					charCostume = SaveData.protagcostume;
				case 'monika':
					charCostume = SaveData.monikacostume;
				case "yuri":
					charCostume = SaveData.yuricostume;
				case 'sayori':
					charCostume = SaveData.sayoricostume;
				case 'natsuki':
					charCostume = SaveData.natsukicostume;
				case 'gf':
					charCostume = SaveData.gfcostume;
				case 'bf':
					charCostume = SaveData.bfcostume;
			}
		}
		var barColor:FlxColor = forceColor;
		if (costumeJSON.list[curSelected].costumes[costumeSelected].color != null && forceColor == 0xFFFDDBF1)
			barColor = FlxColor.fromString(costumeJSON.list[curSelected].costumes[costumeSelected].color);

		var goku:FlxColor = FlxColor.fromHSB(barColor.hue, barColor.saturation, barColor.brightness * 1.3);

		if (charCostume != null && charCostume != 'hueh' && charCostume != '')
			chara.loadGraphic(Paths.image('costume/' + char + '-' + charCostume, 'preload'));
		else
			chara.loadGraphic(Paths.image('costume/' + char, 'preload'));

		if (costumeUnlocked[curSelected][costumeSelected])
		{
			// JSON array is always ordered, so should be fine
			var text:String = LangUtil.getString(costumeJSON.list[curSelected].costumes[costumeSelected].desc, 'costume');

			// Descriptions for hidden costumes
			switch (char)
			{
				case 'natsuki':
				{
					switch (charCostume)
					{
						case 'buff':
							text = LangUtil.getString('descBuff_NA', 'costume');
					}
				}
				case 'bf':
				{
					switch (charCostume)
					{
						case 'sutazu':
							text = LangUtil.getString('descSutazu', 'costume');
					}
				}
				case 'gf':
				{
					switch (charCostume)
					{
						case 'sayo':
							text = LangUtil.getString('descSayoGF', 'costume');
					}
				}
			}

			flavorText.text = text;
		}
		else
		{
			var text:String = '';

			// Checking unlock value if its null or not
			if (costumeJSON.list[curSelected].costumes[costumeSelected].unlock != null)
				text = LangUtil.getString(costumeJSON.list[curSelected].costumes[costumeSelected].unlock, 'costume');
			else
				text = "Unlocked by default.";

			flavorText.text = LangUtil.getString('cmnLock') + ": " + text;
		}
	}

	function costumeselect(goku:Bool)
	{
		var daChoice:String = character[curSelected];
		BSLTouchUtils.prevTouched = -1;

		if (goku)
		{
			flavorText.visible = true;
			flavorBar.visible = true;

			GlobalSoundManager.play('confirmMenu');

			var daSelection = costumeJSON.list[curSelected];
			trace(daSelection);

			grpControlshueh = new FlxTypedGroup<FlxText>();
			add(grpControlshueh);

			for (i in 0...daSelection.costumes.length)
			{
				hueh = daSelection.costumes.length;

				if (costumeUnlocked[curSelected][i])
				{
					var label:String = LangUtil.getString(daSelection.costumes[i].name, 'costume');
					costumeLabel = new FlxText(60, (40 * i) + 370, 0, label, 3);
				}
				else
					costumeLabel = new FlxText(60, (40 * i) + 370, 0, "???", 3);

				costumeLabel.setFormat(LangUtil.getFont('riffic'), 38, FlxColor.WHITE, CENTER);
				costumeLabel.y += LangUtil.getFontOffset('riffic');
				costumeLabel.scale.set(0.7, 0.7);
				costumeLabel.updateHitbox();
				costumeLabel.setBorderStyle(OUTLINE, 0xFFFF7CFF, 2);
				costumeLabel.antialiasing = SaveData.globalAntialiasing;
				costumeLabel.ID = i;
				grpControlshueh.add(costumeLabel);

			}

			costumeSelected = 0;
			selectingcostume = true;
			grpControls.visible = false;

			changecostume();
		}
		else
		{
			flavorText.visible = false;
			flavorBar.visible = false;
			remove(grpControlshueh);
			costumeSelected = 0;
			selectingcostume = false;
			grpControls.visible = true;

			chara.color = 0xFFFFFF;
			loadcharacter(daChoice);
		}
	}

	function changeItem(huh:Int = 0) //PT1
	{
		GlobalSoundManager.play('scrollMenu');
		curSelected += huh;

		var daChoice:String = character[curSelected];

		if (!selectingcostume)
		{
			chara.color = 0xFFFFFF;
			loadcharacter(daChoice);
		}

		grpControls.forEach(function(txt:FlxText)
		{
			if (txt.ID == curSelected)
				txt.setBorderStyle(OUTLINE, 0xFFFFCFFF, 2);
			else
				txt.setBorderStyle(OUTLINE, 0xFFFF7CFF, 2);
		});
	}
							
	function changeItemDirectly(huh:Int = 0) //PT1
	{
		GlobalSoundManager.play('scrollMenu');
		curSelected = huh;

		var daChoice:String = character[curSelected];

		if (!selectingcostume)
		{
			chara.color = 0xFFFFFF;
			loadcharacter(daChoice);
		}

		grpControls.forEach(function(txt:FlxText)
		{
			if (txt.ID == curSelected)
				txt.setBorderStyle(OUTLINE, 0xFFFFCFFF, 2);
			else
				txt.setBorderStyle(OUTLINE, 0xFFFF7CFF, 2);
		});
	}

	function changecostume(huh:Int = 0, goingforward:Bool = true) //PT2
	{
		var daChoice:String = character[curSelected];
		GlobalSoundManager.play('scrollMenu');
		costumeSelected += huh;

		trace(hueh);

		if (costumeSelected >= hueh)
			costumeSelected = 0;
		if (costumeSelected < 0)
			costumeSelected = hueh - 1;

		// Checking for data string value
		var selection = costumeJSON.list[curSelected].costumes[costumeSelected];
		if (selection.data == '')
			loadcharacter(daChoice, 'hueh')
		else
			loadcharacter(daChoice, selection.data);

		if (costumeUnlocked[curSelected][costumeSelected])
			chara.color = 0xFFFFFF;
		else
			chara.color = 0x000000;

		if (grpControlshueh != null)
		{
			grpControlshueh.forEach(function(txt:FlxText)
			{
				if (txt.ID == costumeSelected)
					txt.setBorderStyle(OUTLINE, 0xFFFFCFFF, 2);
				else
					txt.setBorderStyle(OUTLINE, 0xFFFF7CFF, 2);
			});
		}
	}
							
	function changeCostumeDirectly(huh:Int = 0, goingforward:Bool = true) //PT2
	{
		var daChoice:String = character[curSelected];
		GlobalSoundManager.play('scrollMenu');
		costumeSelected = huh;

		trace(hueh);

		if (costumeSelected >= hueh)
			costumeSelected = 0;
		if (costumeSelected < 0)
			costumeSelected = hueh - 1;
		
		//Isso é desnecessário mas é bom para evitar nego safado pilantra ordinaro

		// Checking for data string value
		var selection = costumeJSON.list[curSelected].costumes[costumeSelected];
		if (selection.data == '')
			loadcharacter(daChoice, 'hueh')
		else
			loadcharacter(daChoice, selection.data);

		if (costumeUnlocked[curSelected][costumeSelected])
			chara.color = 0xFFFFFF;
		else
			chara.color = 0x000000;

		if (grpControlshueh != null)
		{
			grpControlshueh.forEach(function(txt:FlxText)
			{
				if (txt.ID == costumeSelected)
					txt.setBorderStyle(OUTLINE, 0xFFFFCFFF, 2);
				else
					txt.setBorderStyle(OUTLINE, 0xFFFF7CFF, 2);
			});
		}
	}

	function savecostume()
	{
		BSLTouchUtils.prevTouched = -1;
		var daChoice:String = character[curSelected];
		var colorthingie:FlxColor = 0xFFFDDBF1;

		// For a better way of getting data value
		var selection = costumeJSON.list[curSelected].costumes[costumeSelected];
		if (costumeUnlocked[curSelected][costumeSelected] #if !PUBLIC_BUILD || FlxG.keys.pressed.F #end)
		{
			switch (curSelected)
			{
				case 6:
					SaveData.protagcostume = selection.data;
				case 5:
					SaveData.yuricostume = selection.data;
				case 4:
					SaveData.natsukicostume = selection.data;

					if (costumeSelected == 0 && FlxG.keys.pressed.B)
						SaveData.natsukicostume = "buff";
				case 3:
					SaveData.sayoricostume = selection.data;
				case 2:
					SaveData.monikacostume = selection.data;

					if (costumeSelected == 1 && (controls.LEFT || controls.RIGHT))
						SaveData.monikacostume = "casuallong";
				case 1:
					SaveData.gfcostume = selection.data;
					
					if (costumeSelected == 0 && FlxG.keys.pressed.B && SaveData.beatCatfight)
					{
						colorthingie = 0xFF94D9FA;
						SaveData.gfcostume = "sayo";
					}
						
					if (costumeSelected == 1 && (controls.LEFT || controls.RIGHT))
						SaveData.gfcostume = "christmas";
				default:
					SaveData.bfcostume = selection.data;

					// Variations
					if (costumeSelected == 0 && FlxG.keys.pressed.B)
					{
						colorthingie = 0xFFFFADD7;
						SaveData.bfcostume = "sutazu";
					}
					if (costumeSelected == 1 && (controls.LEFT || controls.RIGHT))
						SaveData.bfcostume = "christmas";
					if (costumeSelected == 2 && controls.LEFT)
					{
						colorthingie = 0xFFF8F4C1;
						SaveData.bfcostume = "minus-yellow";
					}
					if (costumeSelected == 2 && controls.RIGHT)
					{
						colorthingie = 0xFFBFE6FF;
						SaveData.bfcostume = "minus-mean";
					}
					if (costumeSelected == 3 && (controls.LEFT || controls.RIGHT))
						SaveData.bfcostume = "soft-classic";
					if (costumeSelected == 6 && (controls.LEFT || controls.RIGHT))
						SaveData.bfcostume = "aloe-classic";
			}

			SaveData.save();
			chara.color = 0xFFFFFF;
			loadcharacter(daChoice, colorthingie);

			if (daChoice == "natsuki" && costumeSelected == 0 && SaveData.natsukicostume == "buff")
				FlxG.sound.play(Paths.sound('buff'));
			else
				GlobalSoundManager.play('confirmMenu');

			costumeselect(false);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		logoBl.animation.play('bump', true);
	}
}
