/**
 * User: booster
 * Date: 8/28/13
 * Time: 9:52
 */

package cadet.components.tweens {
import cadet.components.tweens.transitions.CompoundTransition;
import cadet.components.tweens.transitions.ITweenTransition;

public interface ITweenComponent extends IAdvanceableComponent {
    /** Resets this tween and removes from parent. */
    function reset(duration:Number = 1, transition:ITweenTransition = null):void

    /**
     * Sets this tween's current time to a value closest to the given one.
     * This method changes tween's state to 'started' if it wasn't already set, so other properties
     * as duration, delay, repeatCount etc. can't be modified after this call.
     *
     * @param totalTime         new totalTime, including repetitions and repetition delays; negative value means initial delay
     * @param suppressEvents    if true, no events will be dispatched
     * @param parentTransition  parent's transition to apply to the tween along with its own
     * @returns                 new current time (not the given value)
     */
    function seek(totalTime:Number, suppressEvents:Boolean = true, parentTransition:CompoundTransition = null):Number

    /** Indicates if execution of the tween has started. */
    function get started():Boolean

    /** The transition method used for the animation. @see cadet.components.tweens.transitions.ITweenTransition */
    function get transition():ITweenTransition
    function set transition(value:ITweenTransition):void

    /** The total time the tween will take per repetition (in seconds), not including delays. */
    function get duration():Number
    function set duration(value:Number):void

    /** The time that has passed since the tween was created (in seconds). It's negative, if delay is not over. */
    function get cycleTime():Number

    /** The total execution time of the tween (in seconds). It's from 0 to TweenUtil.totalDuration(this). */
    function get totalTime():Number

    /** The current progress between 0 and 1, as calculated by the transition function. */
    function get progress():Number

    /** The delay before the tween is started (in seconds). @default 0 */
    function get delay():Number
    function set delay(value:Number):void

    /** The number of times the tween will be executed.
     *  Set to '0' to tween indefinitely. @default 1 */
    function get repeatCount():int
    function set repeatCount(value:int):void

    /** The amount of time to wait between repeat cycles (in seconds). @default 0 */
    function get repeatDelay():Number
    function set repeatDelay(value:Number):void

    /** The amount of time to wait before this cycle starts executing (it's equal to either delay or repeatDelay). */
    function get currentCycleDelay():Number

    /** Indicates if the tween should be reversed when it is repeating. If enabled,
     *  every second repetition will be reversed. @default false */
    function get repeatReversed():Boolean
    function set repeatReversed(value:Boolean):void

    /** If true, the tween goes from 1 to 0. Can be changed while animating. @default false */
    function get reversed():Boolean
    function set reversed(value:Boolean):void

    /** Indicates if the numeric values should be cast to Integers. @default false */
    function get roundToInt():Boolean
    function set roundToInt(value:Boolean):void
}
}
