package;

import flixel.ui.FlxButton;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
#if mobileC
import flixel.input.actions.FlxActionInput;
import ui.FlxVirtualPad;
#end

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	var _backButton:FlxButton;

	public function addbackButton(semState:Bool = true,?prevState:FlxState)
	{
		_backButton = new FlxButton(50, 50, function()
		{
			if (!semState)
				switchState(prevState); //Assim posso usar esse botão apenas como um mero sprite em situações mais complexas.
		});
		_backButton.loadGraphic(Paths.image('voltar_simples', false, true));
		_backButton.updateHitbox();
		add(_backButton);
	}

	#if mobileC
	var _virtualpad:FlxVirtualPad;

	var trackedinputsUI:Array<FlxActionInput> = [];
	var trackedinputsNOTES:Array<FlxActionInput> = [];

	// adding virtualpad to state
	public function addVirtualPad(?DPad:FlxDPadMode, ?Action:FlxActionMode)
	{
		_virtualpad = new FlxVirtualPad(DPad, Action);
		_virtualpad.alpha = 0.75;
		add(_virtualpad);
		controls.setVirtualPadUI(_virtualpad, DPad, Action);
		trackedinputsUI = controls.trackedinputsUI;
		controls.trackedinputsUI = [];
	}

	override function destroy()
	{
		controls.removeFlxInput(trackedinputsUI);
		controls.removeFlxInput(trackedinputsNOTES);

		super.destroy();
	}
	#end

	override function create()
	{

		GlobalSoundManager.listaDeSons = [];
		CoolUtil.setFPSCap(SaveData.framerate);

		if (!FlxTransitionableState.skipNextTransOut)
			openSubState(new CustomFadeTransition(0.7, true));

		FlxTransitionableState.skipNextTransOut = false;

		// Advance the random seed.
		Random.advance();

		super.create();
	}

	override function update(elapsed:Float)
	{
		var nextStep:Int = updateCurStep();

		if (nextStep >= 0)
		{
			if (nextStep > curStep)
			{
				for (i in curStep...nextStep)
				{
					curStep++;
					updateBeat();
					stepHit();
				}
			}
			else if (nextStep < curStep)
			{
				// Song reset?
				curStep = nextStep;
				updateBeat();
				stepHit();
			}
		}

		if (CoolUtil.getFPSCap() != SaveData.framerate)
			CoolUtil.setFPSCap(SaveData.framerate);

		// let's improve performance of this a tad
		if (FlxG.autoPause != SaveData.autoPause)
			FlxG.autoPause = SaveData.autoPause;

		super.update(elapsed);
	}

	public static function switchState(nextState:FlxState)
	{
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		if (!FlxTransitionableState.skipNextTransIn)
		{
			leState.openSubState(new CustomFadeTransition(0.6, false));
			if (nextState == FlxG.state)
			{
				CustomFadeTransition.finishCallback = function()
				{
					FlxG.resetState();
				};
			}
			else
			{
				CustomFadeTransition.finishCallback = function()
				{
					FlxG.switchState(nextState);
				};
			}
			return;
		}
		FlxTransitionableState.skipNextTransIn = false;
		FlxG.switchState(nextState);
	}

	public static function resetState()
	{
		MusicBeatState.switchState(FlxG.state);
	}

	private function updateBeat():Void
	{
		lastBeat = curBeat;
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		return lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		// do literally nothing dumbass
	}
}
