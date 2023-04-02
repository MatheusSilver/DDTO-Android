package;

class EstadoDeTrocaReverso extends MusicBeatState
{ // Obviamente eu poderia fazer algo mais geral, mas considerando que o problema era só aqui, não havia muito pra eu me preocupar na real
	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory(false);
		PlayState.limparCache = true;
		PlayState.isPlayState = false; //Só pra garantir k

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

		new flixel.util.FlxTimer().start(0.5, function(tmr:flixel.util.FlxTimer)
		{
			if (PlayState.isStoryMode)
				MusicBeatState.switchState(new DokiStoryState());
			else
				MusicBeatState.switchState(new DokiFreeplayState());
		});
	}
}