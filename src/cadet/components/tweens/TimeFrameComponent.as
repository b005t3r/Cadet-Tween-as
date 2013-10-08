/**
 * User: booster
 * Date: 9/3/13
 * Time: 9:46
 */
package cadet.components.tweens {
import cadet.components.tweens.transitions.CompoundTransition;
import cadet.core.ComponentContainer;
import cadet.core.IComponent;
import cadet.events.ValidationEvent;
import cadet.util.TweenUtil;

public class TimeFrameComponent extends ComponentContainer implements ITimeFrameComponent {
    protected static const START_TIME:String    = "startTime";
    protected static const DURATION:String      = "duration";

    protected var _startTime:Number             = 0;
    protected var _currentTime:Number           = 0;
    protected var _childTween:ITweenComponent   = null;
    protected var _childTweenDuration:Number    = 0;

    public function TimeFrameComponent(startTime:Number = 0,  name:String = "TimeFrame") {
        super(name);

        _startTime = startTime;
    }

    public function seek(totalTime:Number, suppressEvents:Boolean = true, parentTransition:CompoundTransition = null):Number {
        if(_childTween == null)
            return 0;

        if(isInvalid(DURATION))
            validateNow();

        // current time goes from 0 fo Infinity (or parent Timeline's duration), so it must not be constrained
        //totalTime       = Math.min(_startTime + _childTweenDuration, Math.max(0, totalTime));
        _currentTime    = totalTime;

        _childTween.seek(_currentTime - _startTime - _childTween.delay, parentTransition);

        return _currentTime;
    }

    public function get childTween():ITweenComponent { return _childTween; }

    public function get currentTime():Number { return _currentTime; }

    public function get startTime():Number { return _startTime; }
    [Serializable][Inspectable(editor="NumberInput", min="0", max="360", numDecimalPlaces="4", priority="60")]
    public function set startTime(value:Number):void {
        _startTime = value;

        invalidate(START_TIME); // only to dispatch the event
    }

    public function get duration():Number {
        if(isInvalid(DURATION))
            validateNow();

        return _childTweenDuration;
    }

    [Serializable][Inspectable(editor="NumberInput", min="0", max="360", numDecimalPlaces="4", priority="61")]
    public function set duration(value:Number):void {
        if(_childTween == null)
            return;

        if(isInvalid(DURATION))
            validateNow();

        var ratio:Number        = value / _childTweenDuration;

        if(ratio < 1) {
            _childTween.duration    = (100.0 * ratio * _childTween.duration) / 100.0;
            _childTween.delay       = (100.0 * ratio * _childTween.delay) / 100.0;
            _childTween.repeatDelay = (100.0 * ratio * _childTween.repeatDelay) / 100.0;
        }
        else {
            _childTween.duration    = ratio * _childTween.duration;
            _childTween.delay       = ratio * _childTween.delay;
            _childTween.repeatDelay = ratio * _childTween.repeatDelay;
        }

        invalidate(DURATION);
    }

    public function advance(dt:Number, parentTransition:CompoundTransition):void {
        if(_childTween == null || dt == 0)
            return;

        if(isInvalid(DURATION))
            validateNow();

        var previousTime:Number = _currentTime;

        _currentTime += dt;

        var endTime:Number = _startTime + _childTweenDuration;

        if((previousTime < _startTime && _currentTime < _startTime)
        || (previousTime > endTime && _currentTime > endTime))
            return;

        var reminder:Number = 0;

        if(dt > 0)  reminder = _currentTime - _startTime;
        else        reminder = _currentTime - endTime;

        if(Math.abs(reminder) < Math.abs(dt))
            _childTween.advance(reminder, parentTransition);
        else
            _childTween.advance(dt, parentTransition);
    }

    protected function onChildTweenInvalidated(event:ValidationEvent):void { invalidate(DURATION); }

    override protected function validate():void {
        if(isInvalid(DURATION))
            _childTweenDuration = _childTween != null ? TweenUtil.totalDuration(_childTween) : 0;

        // START_TIME does not need to be validated

        super.validate();
    }

    override protected function childAdded(child:IComponent, index:uint):void {
        if(_childTween != null || child is ITweenComponent == false)
            throw new Error("TimeFrameComponent can only have one child ITweenComponent");

        super.childAdded(child, index);

        _childTween = ITweenComponent(child);

        _childTween.addEventListener(ValidationEvent.INVALIDATE, onChildTweenInvalidated);

        invalidate(DURATION);
    }

    override protected function childRemoved(child:IComponent):void {
        if(_childTween != null) {
            _childTween.removeEventListener(ValidationEvent.INVALIDATE, onChildTweenInvalidated);

            _childTween = null;

            invalidate(DURATION);
        }

        super.childRemoved(child);
    }
}
}
