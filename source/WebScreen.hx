package;

import flixel.FlxG;
import flixel.FlxSprite;

class WebScreen extends MusicBeatState
{
	override function create()
	{
		super.create();

		var screen:FlxSprite = new FlxSprite().loadGraphic(Paths.image("poornessie"));
        screen.antialiasing = true;
        screen.setGraphicSize(FlxG.width, FlxG.height);
        screen.updateHitbox();
        screen.screenCenter();
		add(screen);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT) FlxG.switchState(new MainMenuState());
	}
}