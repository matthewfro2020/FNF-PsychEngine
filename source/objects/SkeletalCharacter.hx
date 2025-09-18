package objects;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import backend.Paths;
import haxe.Json;
import Lambda;

class SkeletalCharacter extends FlxGroup
{
    public var parts:Array<SkeletalPart> = [];
    public var data:Dynamic;

    public function new(jsonPath:String, ?x:Float = 0, ?y:Float = 0)
    {
        super();

        var raw:String = Paths.getTextFromFile(jsonPath);
        if (raw == null)
        {
            trace("SkeletalCharacter: Could not load " + jsonPath);
            return;
        }

        data = Json.parse(raw);

        // iterate through the parts safely
        for (pd in (data.parts : Array<Dynamic>))
        {
            var p:SkeletalPart = new SkeletalPart(pd, x, y);
            parts.push(p);
            add(p);
        }

        // link parents
        for (p in parts)
        {
            if (Reflect.hasField(p, "parentId") && p.parentId != null)
            {
                var found = Lambda.find(parts, function(pp) return pp.id == p.parentId);
                if (found != null) p.parent = found;
            }
        }
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        for (p in parts) p.updatePart(elapsed);
    }
}
