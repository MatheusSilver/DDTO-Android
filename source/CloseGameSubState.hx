package;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class CloseGameSubState extends MusicBeatSubstate
{
	var curSelected:Int = 2;
	var selectGrp:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();
	var textYes:FlxText;
	var textNo:FlxText;

	public function new()
	{
		super();

		var background:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		background.alpha = 0.5;
		add(background);

		var box:FlxSprite = new FlxSprite().loadGraphic(Paths.image('popup_blank'));
		box.antialiasing = SaveData.globalAntialiasing;
		box.updateHitbox();
		box.screenCenter();
		add(box);

		var text:FlxText = new FlxText(0, box.y + 76, box.frameWidth * 0.95, 'Tem certeza que\nquer sair do jogo?');
		text.setFormat(LangUtil.getFont('aller'), 32, FlxColor.BLACK, FlxTextAlign.CENTER);
		text.y += LangUtil.getFontOffset('aller');
		text.screenCenter(X);
		text.antialiasing = SaveData.globalAntialiasing;
		add(text);

		textYes = new FlxText(box.x + (box.width * 0.18), box.y + (box.height * 0.65), 0, 'Sim');
		textYes.setFormat(LangUtil.getFont('riffic'), 48, FlxColor.WHITE, FlxTextAlign.CENTER);
		textYes.y += LangUtil.getFontOffset('riffic');
		textYes.antialiasing = SaveData.globalAntialiasing;
		textYes.setBorderStyle(OUTLINE, 0xFFFF7CFF, 4);
		textYes.ID = 0;

		textNo = new FlxText(box.x + (box.width * 0.7), box.y + (box.height * 0.65), 0, 'Não');
		textNo.setFormat(LangUtil.getFont('riffic'), 48, FlxColor.WHITE, FlxTextAlign.CENTER);
		textNo.y += LangUtil.getFontOffset('riffic');
		textNo.antialiasing = SaveData.globalAntialiasing;
		textNo.setBorderStyle(OUTLINE, 0xFFFF7CFF, 3);
		textNo.ID = 1;

		selectGrp.add(textYes);
		selectGrp.add(textNo);
		add(selectGrp);

		changeItem();
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (controls.BACK #if android || FlxG.android.justReleased.BACK #end)
			selectItem(1);

		if (BSLTouchUtils.apertasimples(textYes) && curSelected != 0)
			changeItem(0);
		else if (BSLTouchUtils.apertasimples(textNo)  && curSelected != 1)
			changeItem(1);
		else if (BSLTouchUtils.apertasimples(textYes) || BSLTouchUtils.apertasimples(textNo))
			selectItem(curSelected);

		if (controls.LEFT_P)
			changeItem(0);
		if (controls.RIGHT_P)
			changeItem(1);

		if (controls.ACCEPT)
			selectItem(curSelected);
	}

	function changeItem(huh:Int = 0)
	{
		GlobalSoundManager.play('scrollMenu');

		curSelected = huh;

		selectGrp.forEach(function(txt:FlxText)
		{
			if (txt.ID == curSelected)
				txt.setBorderStyle(OUTLINE, 0xFFFFCFFF, 3);
			else
				txt.setBorderStyle(OUTLINE, 0xFFFF7CFF, 3);
		});
	}

	function selectItem(selection:Int = 1):Void
	{
		if (selection == 0)
		{
			Sys.exit(0);
		}
		else
		{
			GlobalSoundManager.play('cancelMenu');
			MusicBeatState.resetState();
			close();
		}
	}
}
