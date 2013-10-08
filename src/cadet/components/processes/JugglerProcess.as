/**
 * User: booster
 * Date: 8/28/13
 * Time: 9:49
 */

package cadet.components.processes {

import cadet.components.tweens.IAdvanceableComponent;
import cadet.components.tweens.transitions.CompoundTransition;
import cadet.core.ComponentContainer;
import cadet.core.IComponent;
import cadet.core.ISteppableComponent;

public class JugglerProcess extends ComponentContainer implements ISteppableComponent {
    protected static var _compoundTransition:CompoundTransition = new CompoundTransition();

    private var _timeScale:Number       = 1.0;
    private var _paused:Boolean         = false;

    public function JugglerProcess(name:String = "TweenProcess") {
        super(name);
    }

    /** Ratio used to scale each time interval passed to children (may be negative). @default 1.0 */
    [Serializable][Inspectable(editor="NumberInput", min="-1000", max="1000", numDecimalPlaces="2", priority="50")]
    public function set timeScale(value:Number):void { _timeScale = value; }
    public function get timeScale():Number { return _timeScale; }

    /** Is this Juggler currently paused or not. @default false */
    [Serializable][Inspectable(editor="CheckBox", priority="51")]
    public function set paused(value:Boolean):void { _paused = value; }
    public function get paused():Boolean { return _paused; }

    public function step(dt:Number):void {
        if(_paused) return;

        var scaledDt:Number = dt * _timeScale;

        for each (var child:IComponent in children) {
            var advanceable:IAdvanceableComponent = child as IAdvanceableComponent;

            if(advanceable == null)
                continue;

            _compoundTransition.removeAllTransitions();
            advanceable.advance(scaledDt, _compoundTransition);
        }
    }
}
}
