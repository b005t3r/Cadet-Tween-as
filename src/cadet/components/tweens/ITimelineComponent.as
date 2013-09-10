/**
 * User: booster
 * Date: 8/28/13
 * Time: 10:18
 */

package cadet.components.tweens {
import cadet.components.tweens.ITweenComponent;
import cadet.core.IComponentContainer;

public interface ITimelineComponent extends ITweenComponent, IComponentContainer {

    /**
     * Adds a tween (wrapped in time frame) to the timeline.
     *
     * @param tween     tween to add
     * @param startTime when this tween should start (if NaN, it's appended at the end)
     */
    function addTween(tween:ITweenComponent, startTime:Number = Number.NaN):void

    /** Execution of timeline can be paused. @default false */
    function get paused():Boolean
    function set paused(value:Boolean):void
}
}
