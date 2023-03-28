package;

class EstadoDeTroca extends MusicBeatState
{ // Obviamente eu poderia fazer algo mais geral, mas considerando que o problema era só aqui, não havia muito pra eu me preocupar na real
	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		PlayState.limparCache = true;

		new flixel.util.FlxTimer().start(1.0, function(tmr:flixel.util.FlxTimer)
		{
			LoadingState.loadAndSwitchState(new PlayState(), true, true);
		});
	}
}