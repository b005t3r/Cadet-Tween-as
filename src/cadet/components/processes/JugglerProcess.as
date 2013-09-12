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
    private static var _compoundTransition:CompoundTransition = new CompoundTransition();

    public function JugglerProcess(name:String = "TweenProcess") {
        super(name);
    }

    public function step(dt:Number):void {
        for each (var child:IComponent in children) {
            var advanceable:IAdvanceableComponent = child as IAdvanceableComponent;

            if(advanceable == null)
                continue;

            _compoundTransition.removeAllTransitions();
            advanceable.advance(dt, _compoundTransition);
        }
    }
}
}
