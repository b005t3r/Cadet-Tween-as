/**
 * User: booster
 * Date: 8/29/13
 * Time: 10:04
 */
package cadet.components.tweens.transitions {
import cadet.components.processes.*;

public class EaseOutInTransition implements ITweenTransition {
    public function get name():String {
        return "Ease Out-In";
    }

    public function value(v:Number):Number {
        return TweenTransitions.combine(TweenTransitions.EASE_OUT, TweenTransitions.EASE_IN, v);
    }
}
}
