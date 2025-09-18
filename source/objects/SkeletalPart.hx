package objects;

import flixel.FlxSprite;
import backend.Paths;

class SkeletalPart extends FlxSprite
{
    public var id:String;
    public var parentId:String;
    public var parent:SkeletalPart;

    public function new(pd:Dynamic, ?x:Float = 0, ?y:Float = 0)
    {
        super(x, y);

        id = pd.id;
        parentId = pd.parent;

        if (Reflect.hasField(pd, "image"))
        {
            var imgPath:String = pd.image;
            loadGraphic(Paths.image(imgPath));
        }

        if (Reflect.hasField(pd, "frame"))
        {
            animation.addByPrefix("default", pd.frame, 24, false);
            animation.play("default");
        }

        if (Reflect.hasField(pd, "x")) this.x += pd.x;
        if (Reflect.hasField(pd, "y")) this.y += pd.y;
    }

    public function updatePart(elapsed:Float):Void
    {
        if (parent != null)
        {
            // follow parent’s transform
            this.x = parent.x + this.x;
            this.y = parent.y + this.y;
        }
    }
}
