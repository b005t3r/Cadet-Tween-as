/**
 * User: booster
 * Date: 8/31/13
 * Time: 10:50
 */

package cadet.components.tweens {
import cadet.components.tweens.transitions.CompoundTransition;
import cadet.core.IComponentContainer;

public interface ITimeFrameComponent extends IAdvanceableComponent, IComponentContainer {
    /**
     * Sets this tween's current time to a value closest to the given one.
     *
     * @param totalTime         new totalTime, including repetitions and repetition delays; negative value means initial delay
     * @param suppressEvents    if true, no events will be dispatched
     * @param parentTransition  compound transition fo all parent timelines
     * @returns                 new current time (not the given value)
     */
    function seek(totalTime:Number, suppressEvents:Boolean = true, parentTransition:CompoundTransition = null):Number

    /** The time that has passed since this time frame was created (in seconds). */
    function get currentTime():Number

    /** When does the time frame start. */
    function get startTime():Number
    function set startTime(value:Number):void

    /** How long does the time frame take. */
    function get duration():Number
    function set duration(value:Number):void

}
}
