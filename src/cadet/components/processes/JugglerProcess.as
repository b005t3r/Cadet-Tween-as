/**
 * User: booster
 * Date: 8/28/13
 * Time: 9:49
 */

package cadet.components.processes {

import cadet.components.tweens.IAdvanceableComponent;
import cadet.core.ComponentContainer;
import cadet.core.IComponent;
import cadet.core.ISteppableComponent;

public class JugglerProcess extends ComponentContainer implements ISteppableComponent {
    public function JugglerProcess(name:String = "TweenProcess") {
        super(name);
    }

    public function step(dt:Number):void {
        for each (var child:IComponent in children) {
            var advanceable:IAdvanceableComponent = child as IAdvanceableComponent;

            if(advanceable == null)
                continue;

            advanceable.advance(dt);
        }
    }
}
}
