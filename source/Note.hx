package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import PlayState;

using StringTools;

class Note extends FlxSprite
{
	public static inline var DEFAULT:Int = 0;
	public static inline var HURT:Int = 1;

	public var isNormal:Bool = false;
	public var isHurt:Bool = false;
	public var noteType:Int = DEFAULT;

	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var modifiedByLua:Bool = false;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var rawNoteData:Int = 0;

	public static var swagWidth:Float = 160 * 0.7;

	public var rating:String = "shit";

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, type:Int = DEFAULT)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		if (this.strumTime < 0)
			this.strumTime = 0;

		this.noteData = noteData;

		this.noteType = type;
		isNormal = type == DEFAULT;
		isHurt = type == HURT;

		if(isSustainNote && prevNote.isHurt) {
			isHurt = true;
		}

		if(isNormal) {
			frames = Paths.getSparrowAtlas('NOTE_assets');

			if (isSustainNote)
			{
				animation.addByPrefix('purpleholdend', 'pruple end hold');
				animation.addByPrefix('greenholdend', 'green hold end');
				animation.addByPrefix('redholdend', 'red hold end');
				animation.addByPrefix('blueholdend', 'blue hold end');

				animation.addByPrefix('purplehold', 'purple hold piece');
				animation.addByPrefix('greenhold', 'green hold piece');
				animation.addByPrefix('redhold', 'red hold piece');
				animation.addByPrefix('bluehold', 'blue hold piece');
			} else {
				animation.addByPrefix('greenScroll', 'green0');
				animation.addByPrefix('redScroll', 'red0');
				animation.addByPrefix('blueScroll', 'blue0');
				animation.addByPrefix('purpleScroll', 'purple0');
			}

			setGraphicSize(Std.int(width * 0.7));
			updateHitbox();
			antialiasing = true;
		}
		else if(isHurt)
		{
			frames = Paths.getSparrowAtlas('HURTNOTE_assets', 'elmosco');
			//if(!FlxG.save.data.downscroll)
			//{
			//	animation.addByPrefix('blueScroll', 'blue fire');
			//	animation.addByPrefix('greenScroll', 'green fire');
			//}
			//else
			//{
			//	animation.addByPrefix('greenScroll', 'blue fire');
			//	animation.addByPrefix('blueScroll', 'green fire');
			//	flipY = true;
			//}
			if (isSustainNote)
			{
				animation.addByPrefix('purpleholdend', 'pruple end hold');
				animation.addByPrefix('greenholdend', 'green hold end');
				animation.addByPrefix('redholdend', 'red hold end');
				animation.addByPrefix('blueholdend', 'blue hold end');

				animation.addByPrefix('purplehold', 'purple hold piece');
				animation.addByPrefix('greenhold', 'green hold piece');
				animation.addByPrefix('redhold', 'red hold piece');
				animation.addByPrefix('bluehold', 'blue hold piece');
			} else {
				animation.addByPrefix('greenScroll', 'green0');
				animation.addByPrefix('redScroll', 'red0');
				animation.addByPrefix('blueScroll', 'blue0');
				animation.addByPrefix('purpleScroll', 'purple0');
			}

			setGraphicSize(Std.int(width * 0.7));
			updateHitbox();
			antialiasing = true;
			//setGraphicSize(Std.int(width * 0.86));
		}

		x += swagWidth * noteData;
		if(!isSustainNote) {
			switch (noteData)
			{
				case 0: animation.play('purpleScroll');
				case 1: animation.play('blueScroll');
				case 2: animation.play('greenScroll');
				case 3: animation.play('redScroll');
			}
		}

		// trace(prevNote);

		// we make sure its downscroll and its a SUSTAIN NOTE (aka a trail, not a note)
		// and flip it so it doesn't look weird.
		// THIS DOESN'T FUCKING FLIP THE NOTE, CONTRIBUTERS DON'T JUST COMMENT THIS OUT JESUS
		if (isSustainNote && FlxG.save.data.downscroll)
			flipY = true;

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;

			x += width / 2;

			switch (noteData)
			{
				case 0:
					animation.play('purpleholdend');
				case 1:
					animation.play('blueholdend');
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
			}

			updateHitbox();

			x -= width / 2;

			if (prevNote.isSustainNote)
			{
				switch (prevNote.noteData)
				{
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
				}

				if(FlxG.save.data.scrollSpeed != 1)
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * FlxG.save.data.scrollSpeed;
				else
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		//No held fire notes :[ (Part 2)
		//if(isSustainNote && prevNote.isHurt) {
		//	this.kill();
		//}

		if (mustPress)
		{
			// ass
			if (isSustainNote)
			{
				if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 1.5)
					&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
					canBeHit = true;
				else
					canBeHit = false;
			}
			else
			{
				if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
					&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset)
					canBeHit = true;
				else
					canBeHit = false;
			}

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset * Conductor.timeScale && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}

	public static function getNoteType(note:Array<Dynamic>) {
		var noteType = note.length > 3 ? note[3] : Note.DEFAULT;
		return noteType;
	}
}