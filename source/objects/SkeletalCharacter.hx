package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import sys.FileSystem;
import haxe.Json;

class SkeletalCharacter extends FlxGroup
{
    public var parts:Array<SkeletalPart>;
    public var rootX:Float;
    public var rootY:Float;

    public function new(data:Dynamic, startX:Float, startY:Float)
    {
        super();

        rootX = startX;
        rootY = startY;

        parts = [];

        // Parse data.parts array
        for (pd in data.parts)
        {
            var partId:String = pd.id;
            var img:String = pd.image;
            var parent:String = Reflect.hasField(pd, "parent") ? pd.parent : null;
            var x:Float = Reflect.hasField(pd, "x") ? pd.x : 0;
            var y:Float = Reflect.hasField(pd, "y") ? pd.y : 0;
            var angle:Float = Reflect.hasField(pd, "angle") ? pd.angle : 0;
            var scaleX:Float = Reflect.hasField(pd, "scaleX") ? pd.scaleX : 1;
            var scaleY:Float = Reflect.hasField(pd, "scaleY") ? pd.scaleY : scaleX;

            var sp:FlxSprite = new FlxSprite(rootX + x, rootY + y);
            sp.loadGraphic(Paths.image(img));  // using Psych Engine’s Paths
            sp.origin.set(sp.width/2, sp.height/2); // or custom origin
            sp.angle = angle;
            sp.scale.set(scaleX, scaleY);
            add(sp);

            var skeletalPart = new SkeletalPart(partId, sp, x, y, angle, scaleX, scaleY, parent);
            parts.push(skeletalPart);
        }

        // Establish parent links
        for (p in parts)
        {
            if (p.parentId != null)
                p.parent = parts.find(p2 -> p2.id == p.parentId);
        }
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        // For each part, compute world transform (position, scale, angle)
        for (p in parts)
        {
            if (p.parent != null)
            {
                // Compose with parent transforms
                p.worldX = p.parent.worldX + p.localX * p.parent.scaleX;
                p.worldY = p.parent.worldY + p.localY * p.parent.scaleY;
                p.worldAngle = p.parent.worldAngle + p.angle;
                p.worldScaleX = p.parent.scaleX * p.scaleX;
                p.worldScaleY = p.parent.scaleY * p.scaleY;
            }
            else
            {
                p.worldX = rootX + p.localX;
                p.worldY = rootY + p.localY;
                p.worldAngle = p.angle;
                p.worldScaleX = p.scaleX;
                p.worldScaleY = p.scaleY;
            }

            p.sprite.x = p.worldX;
            p.sprite.y = p.worldY;
            p.sprite.angle = p.worldAngle;
            p.sprite.scale.set(p.worldScaleX, p.worldScaleY);
        }

        // optionally: respond to input for editing, etc.
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
    public var worldX:Float;
    public var worldY:Float;
    public var worldAngle:Float;
    public var worldScaleX:Float;
    public var worldScaleY:Float;

    public function new(id:String, sprite:FlxSprite, localX:Float, localY:Float,
                         angle:Float, scaleX:Float, scaleY:Float,
                         parentId:String)
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
