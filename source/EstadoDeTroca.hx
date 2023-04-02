package;

class EstadoDeTroca extends MusicBeatState
{ // Obviamente eu poderia fazer algo mais geral, mas considerando que o problema era só aqui, não havia muito pra eu me preocupar na real
	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		PlayState.limparCache = true;
		PlayState.isPlayState = true;

		/*
		//tmj meu mano YoshiCrafter, não sei como isso funciona, mas pelo menos tá resolvendo um pouquinho
		@:privateAccess {
			// clear uint8 pools
			for (length => pool in openfl.display3D.utils.UInt8Buff._pools)
			{
				for (b in pool.clear())
					b.destroy();
			}
			openfl.display3D.utils.UInt8Buff._pools.clear();
		}

		Paths.gColetor();
		*/

		//As vezes nem tão junto assim k

		new flixel.util.FlxTimer().start(0.5, function(tmr:flixel.util.FlxTimer)
		{
			if(!PlayState.isPlayState)
				LoadingState.loadAndSwitchState(new PlayState(), true, true);
			else
				LoadingState.loadAndSwitchState(new PlayState());
		});
	}
}