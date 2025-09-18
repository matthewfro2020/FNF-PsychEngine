package states.editors;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import objects.SkeletalCharacter; // <- new class to read skeletal.json
import objects.Character;        // vanilla characters for Cosmetic mode
import sys.FileSystem;
import sys.io.File;
import haxe.Json;

class HybridEditorState extends FlxState
{
    var curChar:SkeletalCharacter;
    var curCosmetic:Character;
    var mode:String = "skeletal"; // "skeletal" or "cosmetic"
    var infoText:FlxText;

    override public function create():Void
    {
        super.create();

        // example: load Raichu Dave by default
        loadCharacter("pokedave");

        infoText = new FlxText(10, 10, 400, "HybridEditorState: Skeletal Mode");
        add(infoText);
    }

    function loadCharacter(name:String):Void
    {
        var jsonPath = "mods/characters/" + name + ".skeletal.json";
        if (FileSystem.exists(jsonPath))
        {
            var raw = File.getContent(jsonPath);
            var data:Dynamic = Json.parse(raw);
            curChar = new SkeletalCharacter(data, 400, 300);
            add(curChar);
            mode = "skeletal";
        }
        else
        {
            curCosmetic = new Character(400, 300, name);
            add(curCosmetic);
            mode = "cosmetic";
        }

        infoText.text = "HybridEditorState: " + mode.toUpperCase() + " (" + name + ")";
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.FIVE) // reload
        {
            remove(curChar);
            remove(curCosmetic);
            loadCharacter("pokedave"); // reload same char
        }

        if (FlxG.keys.justPressed.ONE) // switch Raichu Dave
            loadCharacter("pokedave");

        if (FlxG.keys.justPressed.TWO) // switch Alolan Dave
            loadCharacter("pokedave_alolan");

        if (FlxG.keys.justPressed.THREE) // switch Tristan
            loadCharacter("poketristan");

        if (FlxG.keys.justPressed.FOUR) // switch Bambi
            loadCharacter("pokebambi");
    }
}
