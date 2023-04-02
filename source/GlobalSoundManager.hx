package;

import flixel.FlxG;
#if (flixel >= "5.3.0")
import flixel.sound.FlxSound;
#else
import flixel.system.FlxSound;
#end

class GlobalSoundManager
{
	public static var confirm:FlxSound;
	public static var cancel:FlxSound;
	public static var scroll:FlxSound;
	public static var clickText:FlxSound;

	public static var listaDeSons:Array<String> = []; //Por algum motivo a lista de FlxSound não funfa aqui... Devéras sus

	public static function init(?som:FlxSound):Void
	{
		if (som == confirm){
			confirm = null;
			confirm = new FlxSound().loadEmbedded(Paths.sound('confirmMenu'));
			confirm.volume = 0.7;
			confirm.persist = false;
			FlxG.sound.list.add(confirm);
		}
		
		if (som == cancel)
		{
			cancel = null;
			cancel = new FlxSound().loadEmbedded(Paths.sound('cancelMenu'));
			cancel.volume = 0.7;
			cancel.persist = false;
			FlxG.sound.list.add(cancel);
		}


		if (som == scroll)
		{
			scroll = null;
			scroll = new FlxSound().loadEmbedded(Paths.sound('scrollMenu'));
			scroll.volume = 0.7;
			scroll.persist = false;
			FlxG.sound.list.add(scroll);
		}

		if (som == clickText)
		{
			clickText = null;
			clickText = new FlxSound().loadEmbedded(Paths.sound('clickText'));
			clickText.volume = 0.7;
			clickText.persist = false;
			FlxG.sound.list.add(clickText);
		}

	}

	public static function play(som:String):Void
	{
		if (0.7 > 0)
		{
			switch (som)
			{
				case 'confirmMenu':
					if (!verifiqueSeExisteEentaoadicione(som))
						init(confirm);

					confirm.play(true);
				case 'clickText':
					if (!verifiqueSeExisteEentaoadicione(som))
						init(clickText);

					clickText.play(true);
				case 'scrollMenu':
					if (!verifiqueSeExisteEentaoadicione(som))
						init(scroll);

					scroll.play(true);
				case 'cancelMenu':
					if (!verifiqueSeExisteEentaoadicione(som))
						init(cancel);

					cancel.play(true);
			}
		}
	}

	public static function verifiqueSeExisteEentaoadicione(nome:String):Bool
	{
		if (!listaDeSons.contains(nome)){
			listaDeSons.push(nome);
			return false;
		}else
			return true;
	}
}
