package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.effects.FlxFlicker;

class DokiCards extends MusicBeatSubstate
{
	public static var cardinstance:DokiCards;
	#if mobile
	var camcontrol:FlxCamera;
	#end

	public static var selectedByBot:Bool = false;

	public var acceptInput:Bool = false;
	var select:FlxSprite;
	var funnyChar:String = 'protag';
	public static var charList:Array<String> =  ['Yuri', 'Sayori', 'Monika', 'Natsuki'];
	var selectGrp:FlxTypedGroup<FlxSprite>;
	var curSelected:Int = 0;
	var huehTimer:FlxTimer;

	public function new()
	{
		super();
		cardinstance = this;

		selectedByBot = false;


		var bg:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
			-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);
		FlxTween.tween(bg, {alpha: 0.3}, 0.4, {ease: FlxEase.quartInOut});

		selectGrp = new FlxTypedGroup<FlxSprite>();
		add(selectGrp);

		for (i in 0...charList.length)
		{
			var funnyx:Int = 69;

			var funnySprite:FlxSprite = new FlxSprite(funnyx + (i * 294), 164);
			funnySprite.frames = Paths.getSparrowAtlas('extraui/' + charList[i] + 'Card', 'preload');
			switch(charList[i])
			{
				case 'Natsuki':
					funnySprite.animation.addByPrefix('pop', 'NatCardAnim', 24, false);
				case 'Monika':
					funnySprite.animation.addByPrefix('pop', 'MonikaCardAnim', 24, false);
				case 'Sayori':
					funnySprite.animation.addByPrefix('pop', 'SayoCardAnim', 24, false);
				case 'Yuri':
					funnySprite.animation.addByPrefix('pop', 'YuriCardAnim', 24, false);
			}
			funnySprite.ID = i;
			funnySprite.animation.play('pop');
			funnySprite.antialiasing = SaveData.globalAntialiasing;
			selectGrp.add(funnySprite);
		}

		select = new FlxSprite(0, 0).loadGraphic(Paths.image('extraui/selecttext', 'preload'));
		select.antialiasing = SaveData.globalAntialiasing;
		select.scale.set(0.8, 0.8);
		select.updateHitbox();
		select.screenCenter(X);
		select.y = -select.height;
		add(select);

		FlxTween.tween(select, {y: 40}, 0.5, {ease: FlxEase.sineOut});

		huehTimer = new FlxTimer().start(8, function(swagTimer:FlxTimer)
		{
			acceptInput = false;
			charSelected(funnyChar);
		});

		if(SaveData.botplay){
			new FlxTimer().start(4, function(swagTimer:FlxTimer)
			{
				selectedByBot = true;
				selectChar('natsuski', 3); //O bug era tão legal que eu quis tornar ele uma mecânica k
			});
		}

		new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			acceptInput = true;
		});

		#if mobileC
		if (!SaveData.botplay){
			addVirtualPad(EU_TU_NOIS_BOTA_NELA, NONE);
			camcontrol = new FlxCamera();
			FlxG.cameras.add(camcontrol);
			camcontrol.bgColor.alpha = 0;
			_virtualpad.cameras = [camcontrol];
		}
		#end

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (acceptInput && !SaveData.botplay)
		{ //A camera dessa bosta não permite que eu use touch aqui...
			if (controls.LEFT_P) //Se fosse NOTE_LEFT_P, ele usaria a hitbox/controles do fundo...
				selectChar('yuri', 0);
			if (controls.DOWN_P)
				selectChar('sayori', 1);
			if (controls.UP_P)
				selectChar('monika', 2);
			if (controls.RIGHT_P)
				selectChar('natsuki', 3);
			
		}
	}

	function selectChar(who:String = 'protag', num:Int)
	{
		huehTimer.cancel();
		//tween the cards away except the selected card
		acceptInput = false;
		funnyChar = who;
		curSelected = num;
		GlobalSoundManager.play('confirmMenu');

		selectGrp.forEach(function(hueh:FlxSprite)
		{
			if (hueh.ID != curSelected)
				FlxTween.tween(hueh, {y: 1280}, 1, {ease: FlxEase.circIn});
			else if (SaveData.flashing && hueh.ID == curSelected)
				FlxFlicker.flicker(hueh, 1, 0.1, false, false);

		});

		huehTimer = new FlxTimer().start(1, function(swagTimer:FlxTimer)
		{
			charSelected(funnyChar);
		});
	}
	function charSelected(?who:String)
	{
		selectGrp.forEach(function(hueh:FlxSprite)
		{
			FlxTween.tween(hueh, {alpha: 0}, 0.5, {ease: FlxEase.circIn, onComplete: function(twn:FlxTween){}});
		});
		FlxTween.tween(select, {alpha: 0}, 1, {ease: FlxEase.linear});
		#if mobile
		if(!SaveData.botplay)
			FlxTween.tween(camcontrol, {alpha: 0}, 0.5, {ease: FlxEase.linear});
		#end
		//tween selected card with alpha
		new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			PlayState.instance.cardSelected(who);
			FlxTween.tween(PlayState.instance.camHUD, {alpha: 1}, 2, {ease: FlxEase.sineOut});
			close();
		});
	}
}
