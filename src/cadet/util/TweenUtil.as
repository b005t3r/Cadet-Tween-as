/**
 * User: booster
 * Date: 8/30/13
 * Time: 16:17
 */
package cadet.util {
import cadet.components.tweens.ITweenComponent;
import cadet.components.processes.*;

public class TweenUtil {
    /** Total duration of this tween, including delay, repeat delay and each repetition. Returns Infinity if repeatCount is 0. */
    public static function totalDuration(tween:ITweenComponent):Number {
        if(tween.repeatCount == 0)
            return Infinity;

        if(tween.repeatCount == 1)
            return tween.delay + tween.duration;
        else
            return tween.delay + tween.repeatCount * tween.duration + (tween.repeatCount - 1) * tween.repeatDelay;
    }

    public static function roundTime(time:Number):Number {
        return Math.round(time * 1000000) / 1000000;
    }

    public function TweenUtil() { throw new UninitializedError("this is a static class"); }
}
}
