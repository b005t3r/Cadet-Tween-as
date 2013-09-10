/**
 * User: booster
 * Date: 8/29/13
 * Time: 10:03
 */
package cadet.components.tweens.transitions {
import cadet.components.processes.*;

public class LinearTransition implements ITweenTransition {
    public function get name():String {
        return "Linear";
    }

    public function value(v:Number):Number {
        return v;
    }
}
}
