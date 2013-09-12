/**
 * User: booster
 * Date: 8/30/13
 * Time: 13:19
 */

package cadet.components.tweens {

import cadet.components.tweens.transitions.CompoundTransition;
import cadet.components.tweens.transitions.ITweenTransition;
import cadet.components.tweens.transitions.TweenTransitions;
import cadet.core.IComponent;
import cadet.events.ValidationEvent;

public class TimelineComponent extends AbstractTweenComponent implements ITimelineComponent {
    protected var _started:Boolean      = false;
    protected var _paused:Boolean       = false;
    protected var _prevProgress:Number  = 0;

    public function TimelineComponent(time:Number = 0, transition:ITweenTransition = null, name:String = "Timeline") {
        super(time, transition, name);

        reset(time, transition);
    }

    public function addTween(tween:ITweenComponent, startTime:Number = Number.NaN):void {
        if(started)
            throw new Error("tween already started, call reset() first");

        var timeFrame:TimeFrameComponent = new TimeFrameComponent(/* isNaN check */ startTime != startTime ? duration : startTime);

        timeFrame.children.addItem(tween);
        children.addItem(timeFrame);
    }

    public function get paused():Boolean { return _paused; }
    public function set paused(value:Boolean):void { _paused = value; }

    override public function get duration():Number {
        if(isInvalid(DURATION))
            validateNow();

        return _duration;
    }

    override public function set duration(value:Number):void {
        if(isInvalid(DURATION))
            validateNow();

        var ratio:Number = value / _duration;

        for each (var timeFrame:ITimeFrameComponent in children) {
            if(ratio < 1) {
                timeFrame.duration  = (100.0 * ratio * timeFrame.duration) / 100.0;
                timeFrame.startTime = (100.0 * ratio * timeFrame.startTime) / 100.0;
            }
            else {
                timeFrame.duration  = ratio * timeFrame.duration;
                timeFrame.startTime = ratio * timeFrame.startTime;
            }
        }

        invalidate(DURATION);
    }

    override public function advance(dt:Number, parentTransition:CompoundTransition):void {
        _prevProgress = _progress;

        super.advance(dt, parentTransition);
    }

    override public function seek(totalTime:Number, suppressEvents:Boolean = true, parentTransition:CompoundTransition = null):Number {
        // don't call super.seek()
        _prevProgress = _progress;

        seekImpl(totalTime, suppressEvents, parentTransition);

        if(parentTransition != null)
            parentTransition.pushTransition(_transition);

        for each (var timeFrame:ITimeFrameComponent in children)
            timeFrame.seek(totalTime, parentTransition);

        if(parentTransition != null)
            parentTransition.popTransition();

        return _currentTime;
    }

    override public function get started():Boolean { return _started;}

    override protected function isReadyToStart():Boolean { return true; }
    override protected function animationStarted():void { _started = true; }

    override protected function animationUpdated(parentTransition:CompoundTransition):void {
        var dt:Number = _duration * _progress - _duration * _prevProgress;

        if(dt == 0)
            return;

        for each (var timeFrame:ITimeFrameComponent in children) {
            var diff:Number = timeFrame.startTime + timeFrame.duration - timeFrame.currentTime;

            //if(diff <= 0)
            //    continue;

            if(_progress == 1 && dt > 0)
                timeFrame.advance(Math.ceil(diff * 1000000) / 1000000, parentTransition); // to solve floating-point accuracy problems
            else if(_progress == 0 && dt < 0)
                timeFrame.advance(Math.floor(diff * 1000000) / 1000000, parentTransition); // to solve floating-point accuracy problems
            else
                timeFrame.advance(dt, parentTransition);
        }
    }

    override protected function animationRepeated():void {
        var revRep:Boolean = _repeatReversed && (_currentCycle % 2 == 1);

        for each (var timeFrame:ITimeFrameComponent in children) {
            timeFrame.seek(! revRep ? 0 : _duration);
        }
    }

    override protected function calculateProgress(time:Number, trans:ITweenTransition):Number {
        // apply transition only to children, not self
        return super.calculateProgress(time, TweenTransitions.LINEAR);
    }

    protected function onChildInvalidated(event:ValidationEvent):void { invalidate(DURATION); }

    override protected function childAdded(child:IComponent, index:uint):void {
        if(child is ITimeFrameComponent == false)
            throw new Error("all children of TimelineComponent has to implement ITimeFrameComponent interface");

        super.childAdded(child, index);

        var timeFrame:ITimeFrameComponent = ITimeFrameComponent(child);

        timeFrame.addEventListener(ValidationEvent.INVALIDATE, onChildInvalidated);

        invalidate(DURATION);
    }

    override protected function childRemoved(child:IComponent):void {
        var timeFrame:ITimeFrameComponent = ITimeFrameComponent(child);

        timeFrame.removeEventListener(ValidationEvent.INVALIDATE, onChildInvalidated);

        super.childRemoved(child);

        invalidate(DURATION);
    }

    override protected function validate():void {
        if(isInvalid(DURATION))
            validateDuration();

        super.validate();
    }

    protected function validateDuration():void {
        _duration = 0;

        for each (var timeFrame:ITimeFrameComponent in children)
            _duration = Math.max(_duration, timeFrame.startTime + timeFrame.duration);

        trace("duration: " + _duration);
    }
}
}
