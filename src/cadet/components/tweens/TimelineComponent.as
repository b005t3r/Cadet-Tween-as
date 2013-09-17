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
    protected var _started:Boolean                                  = false;
    protected var _paused:Boolean                                   = false;
    protected var _prevProgress:Number                              = 0;
    protected var _sortedTimeFrames:Vector.<ITimeFrameComponent>    = null; // initialized on start

    public function TimelineComponent(time:Number = 0, transition:ITweenTransition = null, name:String = "Timeline") {
        super(time, transition, name);

        reset(time, transition);
    }

    public function addTween(tween:ITweenComponent, startTime:Number = Number.NaN):void {
        if(started)
            throw new Error("tween already started, call reset() first");

        var timeFrame:TimeFrameComponent = new TimeFrameComponent(/* isNaN check */ startTime != startTime ? duration : startTime);

        timeFrame.children.addItem(tween);
        children.addItem(timeFrame); // invalidates Timeline's duration
    }

    public function get paused():Boolean { return _paused; }
    public function set paused(value:Boolean):void { _paused = value; }

    override public function reset(duration:Number = 0, transition:ITweenTransition = null):void {
        _started            = false;
        _paused             = false;
        _prevProgress       = 0;
        _sortedTimeFrames   = null;

        super.reset(duration, transition);
    }

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
        if(_paused)
            return;

        _prevProgress = _progress;

        super.advance(dt, parentTransition);
    }

    override public function seek(totalTime:Number, suppressEvents:Boolean = true, parentTransition:CompoundTransition = null):Number {
        var prevTotalTime:Number    = this.totalTime;
        var dt:Number               = totalTime - prevTotalTime;

        if(parentTransition == null)
            parentTransition = new CompoundTransition();

        var oldPaused:Boolean = _paused;
        _paused = false;

        advance(dt, parentTransition);

        _paused = oldPaused;

        return _cycleTime;
    }

    override public function get started():Boolean { return _started;}

    protected function sortedTimeFrames(fromStart:Boolean = true):Vector.<ITimeFrameComponent> {
        var vec:Vector.<ITimeFrameComponent> = new <ITimeFrameComponent>[];

        var count:int = children.length;
        for(var i:int = 0; i < count; i++) {
            var timeFrame:ITimeFrameComponent = ITimeFrameComponent(children[i]);
            vec.push(timeFrame);
        }

        vec.sort(function compare(x:ITimeFrameComponent, y:ITimeFrameComponent):Number {
            // should descending compare finish times?
            return fromStart
                ? x.startTime - y.startTime
                : (y.startTime + y.duration) - (x.startTime + x.duration);
        });

        return vec;
    }

    override protected function isReadyToStart():Boolean { return true; }
    override protected function animationStarted():void {
        _started = true;

        _sortedTimeFrames = sortedTimeFrames(true);
    }

    override protected function animationUpdated(parentTransition:CompoundTransition):void {
        var dt:Number   = _duration * _progress - _duration * _prevProgress;

        if(dt == 0)
            return;

        var count:int = _sortedTimeFrames.length;
        for (var i:int = 0; i < count; i++) {
            var timeFrame:ITimeFrameComponent = _sortedTimeFrames[i];

            var diff:Number = timeFrame.startTime + timeFrame.duration - timeFrame.currentTime;

            if(_progress == 1 && dt > 0)
                timeFrame.advance(Math.ceil(diff * 1000000) / 1000000, parentTransition); // to solve floating-point accuracy problems
            else if(_progress == 0 && dt < 0)
                timeFrame.advance(Math.floor(-timeFrame.currentTime * 1000000) / 1000000, parentTransition); // to solve floating-point accuracy problems
            else
                timeFrame.advance(dt, parentTransition);
        }
    }

    override protected function animationRepeated():void {
        var rev:Boolean = _repeatReversed && (_currentCycle % 2 == 1);

        _sortedTimeFrames = sortedTimeFrames(! rev);

        for (var i:int = _sortedTimeFrames.length - 1; i >= 0; i--) {
            var timeFrame:ITimeFrameComponent = _sortedTimeFrames[i];

            timeFrame.seek(! rev ? 0 : _duration);
        }
    }

    override protected function calculateProgress(time:Number, trans:ITweenTransition):Number {
        // apply transition only to children, not self
        // TODO: is this OK?
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
    }
}
}
