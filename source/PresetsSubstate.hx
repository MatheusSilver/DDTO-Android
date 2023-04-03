package; //Ainda incompleto... Mas já são 4 da manhã e eu tô com sono...

import flixel.input.gamepad.FlxGamepad;
import flixel.util.FlxAxes;
import flixel.FlxSubState;
import Options.Option;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import lime.utils.Assets;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.input.FlxKeyManager;

using StringTools;

class PresetsSubstate extends MusicBeatSubstate
{
	var keyTextDisplay:FlxText;
	var curSelected:Int = 0;

	var judgementText:Array<String> = ["Gama Alta (4GB+)", "Gama Média(3GB+)", "Gama Baja(2GB+)", "Voltar", ''];

	var explicacoes:Array<String> = [
		"Tudo do mod original estará ativado (recomendado para acima de 4 GB de RAM)", 
		"A notificação de acerto não estará visível e irá estabilizar o FPS (recomendado para 3 GB de RAM)", 
		"Removerá detalhes consideráveis do jogo, mas ainda poderá acompanhar a história principal (recomendado para 2 GB de RAM)", 
		"Você não estará escolhendo nenhum preset. Clique novamente para voltar ao menu.",
		''];

	var blackBox:FlxSprite;
	var infoText:FlxText;

	var acceptInput:Bool = false;

	override function create()
	{
		persistentUpdate = persistentDraw = true;

		keyTextDisplay = new FlxText(-10, 0, 1280, "", 72);
		keyTextDisplay.scrollFactor.set(0, 0);
		keyTextDisplay.setFormat(LangUtil.getFont('riffic'), 42, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, 0xFFFF7CFF);
		keyTextDisplay.y += LangUtil.getFontOffset('riffic');
		keyTextDisplay.borderSize = 2;
		keyTextDisplay.borderQuality = 3;
		keyTextDisplay.antialiasing = SaveData.globalAntialiasing;

		blackBox = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(blackBox);

		infoText = new FlxText(-10, 580, 1280, '', 72);
		infoText.scrollFactor.set(0, 0);
		infoText.setFormat(LangUtil.getFont('riffic'), 21, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, 0xFFFF7CFF);
		infoText.y += LangUtil.getFontOffset('riffic');
		infoText.borderSize = 2;
		infoText.borderQuality = 3;
		infoText.alpha = 0;
		infoText.screenCenter(FlxAxes.X);
		infoText.antialiasing = SaveData.globalAntialiasing;
		add(infoText);
		add(keyTextDisplay);

		blackBox.alpha = 0;
		keyTextDisplay.alpha = 0;

		FlxTween.tween(keyTextDisplay, {alpha: 1}, 1, {ease: FlxEase.expoInOut});
		FlxTween.tween(infoText, {alpha: 1}, 1.4, {ease: FlxEase.expoInOut});
		FlxTween.tween(blackBox, {alpha: 0.7}, 1, {
			ease: FlxEase.expoInOut,
			onComplete: function(flx:FlxTween)
			{
				acceptInput = true;
			}
		});

		OptionsState.instance.acceptInput = false;

		#if mobile
		addVirtualPad(UP_DOWN, A_B);
		#end

		textUpdate();

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (acceptInput)
		{
			if (controls.UP_P)
			{
				GlobalSoundManager.play('scrollMenu');
				changeItem(-1);
				updateJudgement();
			}

			if (controls.DOWN_P)
			{
				GlobalSoundManager.play('scrollMenu');
				changeItem(1);
				updateJudgement();
			}

			if (controls.ACCEPT)
				selecionarpreset();

			if (controls.BACK #if android || FlxG.android.justReleased.BACK #end)
				quit();
		}

		super.update(elapsed);
	}

	function updateJudgement()
	{
		infoText.text = 'Escolha um Preset de otimização\n\n'
			+ judgementText[curSelected]
			+ ': '
			+ explicacoes[curSelected];

		textUpdate();
	}

	function textUpdate()
	{
		keyTextDisplay.text = "\n\n";

		for (i in 0...judgementText.length-1)
		{
			var textStart = (i == curSelected) ? "> " : "  ";
			keyTextDisplay.text += textStart + judgementText[i] + "\n";
		}

		keyTextDisplay.screenCenter();

		infoText = new FlxText(-10, 580, 1280, 'Escolha um Preset de otimização\nToque na opção duas vezes para confirmar\n\n'+ judgementText[curSelected] + ': ' + explicacoes[curSelected], 72);

	}

	function selecionarpreset()
	{
		switch (curSelected)
		{
			case 0:
				SaveData.gpuTextures = false; //Não acho que um gama alta precise, mas...
				SaveData.ratingVisivel = true;
				SaveData.removergirlfriend = false;
				SaveData.globalAntialiasing = true;
				SaveData.lowEnd = false;
				SaveData.flashing = true;
				SaveData.framerate = 90;
			case 1:
				SaveData.gpuTextures = false;
				SaveData.removergirlfriend = false;
				SaveData.ratingVisivel = false;
				SaveData.globalAntialiasing = false;
				SaveData.lowEnd = false;
				SaveData.flashing = true;
				SaveData.framerate = 60;
			case 2:
				SaveData.gpuTextures = false;
				SaveData.ratingVisivel = false;
				SaveData.removergirlfriend = true;
				SaveData.globalAntialiasing = false;
				SaveData.lowEnd = true;
				SaveData.flashing = false;
				SaveData.framerate = 45;
		}

		if (curSelected < 3)
			SaveData.curPreset = curSelected;

		SaveData.save();

		MusicBeatState.switchState(new MainMenuState());
	}

	function save()
	{
		/*SaveData.shitMs = judgementTimings[0];
		SaveData.badMs = judgementTimings[1];
		SaveData.goodMs = judgementTimings[2];
		SaveData.sickMs = judgementTimings[3];

		SaveData.save();

		Ratings.timingWindows = [
			SaveData.shitMs,
			SaveData.badMs,
			SaveData.goodMs,
			SaveData.sickMs
		];

		Conductor.safeZoneOffset = Ratings.timingWindows[0];*/
	}

	function quit()
	{
		save();

		FlxTween.tween(keyTextDisplay, {alpha: 0}, 1, {ease: FlxEase.expoInOut});
		FlxTween.tween(blackBox, {alpha: 0}, 1.1, {
			ease: FlxEase.expoInOut,
			onComplete: function(flx:FlxTween)
			{
				OptionsState.instance.acceptInput = true;
				close();
			}
		});
		FlxTween.tween(infoText, {alpha: 0}, 1, {ease: FlxEase.expoInOut});
	}

	function changeItem(_amount:Int = 0)
	{
		curSelected += _amount;

		if (curSelected > 3)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = 3;
	}
}
