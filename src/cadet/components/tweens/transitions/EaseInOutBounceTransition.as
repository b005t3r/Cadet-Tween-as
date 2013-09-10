/**
 * User: booster
 * Date: 8/29/13
 * Time: 10:04
 */
package cadet.components.tweens.transitions {

import cadet.components.processes.*;

public class EaseInOutBounceTransition implements ITweenTransition {
    public function get name():String {
        return "Bounce Ease In-Out";
    }

    public function value(v:Number):Number {
        return TweenTransitions.combine(TweenTransitions.EASE_IN_BOUNCE, TweenTransitions.EASE_OUT_BOUNCE, v);
    }
}
}
