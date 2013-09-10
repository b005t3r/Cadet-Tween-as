/**
 * User: booster
 * Date: 8/31/13
 * Time: 10:22
 */
package cadet.components.tweens {
import cadet.core.IComponent;

public interface IAdvanceableComponent extends IComponent {
    /** Called by the JugglerProcess, advances this component by dt seconds. */
    function advance(dt:Number):void
}
}
