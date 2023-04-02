package;

//	Isso foi feito para ser usado naqueles vídeos que não nescessariamente trocam de state (cutscene da gf corrompida, monika codin, etc...)

#if mobile
import extension.webview.WebView;
import flixel.FlxG;
import flixel.text.FlxText;

using StringTools;

class VideoSubState extends MusicBeatSubstate
{
	public static var androidPath:String = 'file:///android_asset/';

	var text:FlxText;
	var changecount = 0;

	public function new(source:String)
	{
		super();

		text = new FlxText(0, 0, 0, "Toque para continuar \n caso o jogo não continue", 48);
		text.screenCenter();
		text.alpha = 0;
		add(text);

		// FlxG.autoPause = false;

		WebView.onClose = onClose;
		WebView.onURLChanging = onURLChanging;

		WebView.open(androidPath + source + '.html', false, null, ['http://exitme(.*)']);
	}

	public override function update(dt:Float)
	{
		if (BSLTouchUtils.justTouched() || FlxG.android.justReleased.BACK)
			onClose();

		super.update(dt);
	}

	function onClose()
	{ // not working
		text.alpha = 0;
		changecount = 0;
		// FlxG.autoPause = true;
		trace('aqui cabo!'); //==11x3 Fnatic :skull:
		close();
	}

	function onURLChanging(url:String)
	{
		if (changecount == 2)
			onClose();
		else
			changecount++;
		text.alpha = 1;
		if (url == 'http://exitme(.*)') //Não tenho certeza sobre isso tambem, mas deve fazer com que o player de vídeo feche sozinho.
			onClose(); // drity hack lol
		trace("WebView is about to open: " + url);
	}
}
#end
