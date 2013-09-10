/**
 * User: booster
 * Date: 8/29/13
 * Time: 10:04
 */
package cadet.components.tweens.transitions {
import cadet.components.processes.*;

public class EaseInBounceTransition implements ITweenTransition {
    public function get name():String {
        return "Bounce Ease In";
    }

    public function value(v:Number):Number {
        return 1.0 - TweenTransitions.EASE_OUT_BOUNCE.value(1.0 - v);
    }
}
}
