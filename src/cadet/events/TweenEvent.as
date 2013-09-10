/**
 * User: booster
 * Date: 8/28/13
 * Time: 10:37
 */

package cadet.events {
import cadet.components.tweens.ITweenComponent;
import cadet.components.processes.*;

import flash.events.Event;

public class TweenEvent extends Event {
    public static const STARTED:String  = "started";
    public static const FINISHED:String = "finished";
    public static const ADVANCED:String = "advanced";
    public static const REPEATED:String = "repeated";

    private var _tween:ITweenComponent;

    public function TweenEvent(type:String, tween:ITweenComponent) {
        super(type, false, false);

        this._tween = tween;
    }

    public function get tween():ITweenComponent { return _tween; }

    override public function clone():Event { return new TweenEvent(type, tween); }
}
}
