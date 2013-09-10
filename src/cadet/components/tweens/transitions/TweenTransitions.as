/**
 * User: booster
 * Date: 8/29/13
 * Time: 9:24
 */

package cadet.components.tweens.transitions {
import cadet.components.processes.*;

import cadet.components.tweens.transitions.*;

public class TweenTransitions {
    public static const LINEAR:ITweenTransition                 = new LinearTransition();

    public static const EASE_IN:ITweenTransition                = new EaseInTransition();
    public static const EASE_OUT:ITweenTransition               = new EaseOutTransition();
    public static const EASE_IN_OUT:ITweenTransition            = new EaseInOutTransition();
    public static const EASE_OUT_IN:ITweenTransition            = new EaseOutInTransition();

    public static const EASE_IN_BACK:ITweenTransition           = new EaseInBackTransition();
    public static const EASE_OUT_BACK:ITweenTransition          = new EaseOutBackTransition();
    public static const EASE_IN_OUT_BACK:ITweenTransition       = new EaseInOutBackTransition();
    public static const EASE_OUT_IN_BACK:ITweenTransition       = new EaseOutInBackTransition();

    public static const EASE_IN_ELASTIC:ITweenTransition        = new EaseInElasticTransition();
    public static const EASE_OUT_ELASTIC:ITweenTransition       = new EaseOutElasticTransition();
    public static const EASE_IN_OUT_ELASTIC:ITweenTransition    = new EaseInOutElasticTransition();
    public static const EASE_OUT_IN_ELASTIC:ITweenTransition    = new EaseOutInElasticTransition();

    public static const EASE_IN_BOUNCE:ITweenTransition         = new EaseInBounceTransition();
    public static const EASE_OUT_BOUNCE:ITweenTransition        = new EaseOutBounceTransition();
    public static const EASE_IN_OUT_BOUNCE:ITweenTransition     = new EaseInOutBounceTransition();
    public static const EASE_OUT_IN_BOUNCE:ITweenTransition     = new EaseOutInBounceTransition();

    public static function combine(startTransition:ITweenTransition, endTransition:ITweenTransition, v:Number):Number {
        if(v < 0.5) return 0.5 * startTransition.value(v * 2.0);
        else        return 0.5 * endTransition.value((v - 0.5) * 2.0) + 0.5;
    }

    public function TweenTransitions() { throw new UninitializedError("this is a static class"); }
}
}
