package objects;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import haxe.Json;
import sys.io.File;
import sys.FileSystem;
import Paths;

/**
 * SkeletalCharacter
 *  - Reads {character}.skeletal.json
 *  - Creates per-part sprites (head, body, arms, legs, etc.)
 *  - Applies parent/child transforms (like bones)
 */
class SkeletalCharacter extends FlxGroup
{
    public var parts:Array<SkeletalPart>;
    public var charName:String;
    public var rootX:Float;
    public var rootY:Float;

    public function new(charName:String, startX:Float = 0, startY:Float = 0)
    {
        super();
        this.charName = charName;
        this.rootX = startX;
        this.rootY = startY;
        parts = [];

        var jsonPath:String = 'mods/characters/' + charName + '.skeletal.json';
        if (FileSystem.exists(jsonPath))
        {
            var raw:String = File.getContent(jsonPath);
            var data:Dynamic = Json.parse(raw);
            loadParts(data);
        }
        else
        {
            trace('⚠ SkeletalCharacter: JSON not found: ' + jsonPath);
        }
    }

    function loadParts(data:Dynamic):Void
    {
        for (pd in data.parts)
        {
            var img:String = pd.image;
            var x:Float = Reflect.hasField(pd, "x") ? pd.x : 0;
            var y:Float = Reflect.hasField(pd, "y") ? pd.y : 0;
            var scaleX:Float = Reflect.hasField(pd, "scaleX") ? pd.scaleX : 1;
            var scaleY:Float = Reflect.hasField(pd, "scaleY") ? pd.scaleY : 1;
            var angle:Float = Reflect.hasField(pd, "angle") ? pd.angle : 0;
            var parentId:String = Reflect.hasField(pd, "parent") ? pd.parent : null;

            var sp:FlxSprite = new FlxSprite(rootX + x, rootY + y);
            sp.loadGraphic(Paths.image(img)); // uses Psych Engine’s Paths
            sp.origin.set(sp.width / 2, sp.height / 2);
            sp.angle = angle;
            sp.scale.set(scaleX, scaleY);
            add(sp);

            var part = new SkeletalPart(
                pd.id,
                sp,
                x, y,
                angle,
                scaleX, scaleY,
                parentId
            );
            parts.push(part);
        }

        // Link parents
        for (p in parts)
        {
            if (p.parentId != null)
                p.parent = parts.find(pp -> pp.id == p.parentId);
        }
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        for (p in parts)
        {
            if (p.parent != null)
            {
                // apply parent transforms
                p.worldX = p.parent.sprite.x + p.localX * p.parent.sprite.scale.x;
                p.worldY = p.parent.sprite.y + p.localY * p.parent.sprite.scale.y;
                p.worldAngle = p.parent.sprite.angle + p.angle;
                p.worldScaleX = p.parent.sprite.scale.x * p.scaleX;
                p.worldScaleY = p.parent.sprite.scale.y * p.scaleY;
            }
            else
            {
                // root part
                p.worldX = rootX + p.localX;
                p.worldY = rootY + p.localY;
                p.worldAngle = p.angle;
                p.worldScaleX = p.scaleX;
                p.worldScaleY = p.scaleY;
            }

            // apply to sprite
            p.sprite.x = p.worldX;
            p.sprite.y = p.worldY;
            p.sprite.angle = p.worldAngle;
            p.sprite.scale.set(p.worldScaleX, p.worldScaleY);
        }
    }
}

class SkeletalPart
{
    public var id:String;
    public var sprite:FlxSprite;
    public var localX:Float;
    public var localY:Float;
    public var angle:Float;
    public var scaleX:Float;
    public var scaleY:Float;
    public var parentId:String;
    public var parent:SkeletalPart;

    public var worldX:Float = 0;
    public var worldY:Float = 0;
    public var worldAngle:Float = 0;
    public var worldScaleX:Float = 1;
    public var worldScaleY:Float = 1;

    public function new(
        id:String, sprite:FlxSprite,
        localX:Float, localY:Float,
        angle:Float, scaleX:Float, scaleY:Float,
        parentId:String
    )
    {
        this.id = id;
        this.sprite = sprite;
        this.localX = localX;
        this.localY = localY;
        this.angle = angle;
        this.scaleX = scaleX;
        this.scaleY = scaleY;
        this.parentId = parentId;
        this.parent = null;
    }
}
