package;

import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.FlxG;

class BSLTouchUtils
{
	public static var prevTouched:Int = -1;

	public static function justTouched():Bool //Copiado do Hsys k
	{
		var justTouched:Bool = false;

		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
				justTouched = true;
		}

		#if (flixel && android)
		return justTouched;
		#else
		return FlxG.mouse.justPressed; //Isso aqui é mais válido pro modboa mas né?
		#end
	}

	public static function aperta(coisas:Dynamic, coisasID:Int):String //Esse code foi feito só pq em outro projeto, eu usei um padrãozinho deste várias vezes e fiquei com preguiça de fazer isso de novo
    {
        var leToqueOrdem:String = '';
	    #if desktop
		if (FlxG.mouse.overlaps(coisas) && FlxG.mouse.justPressed && prevTouched == coisasID){
            leToqueOrdem = 'segundo';
		}else if (FlxG.mouse.overlaps(coisas) && FlxG.mouse.justPressed){
			prevTouched = coisasID;
			leToqueOrdem = 'primeiro';
        }
	    #elseif mobile
		   for (touch in FlxG.touches.list){
		if (touch.overlaps(coisas) && touch.justPressed && prevTouched == coisasID){
            leToqueOrdem = 'segundo';
		}else if (touch.overlaps(coisas) && touch.justPressed){
			prevTouched = coisasID;
			leToqueOrdem = 'primeiro';
        }    
		   }
	    #end
		return leToqueOrdem;
    }
}
