/**
 * User: booster
 * Date: 9/3/13
 * Time: 9:46
 */
package cadet.components.tweens {
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

    public function seek(totalTime:Number, suppressEvents:Boolean = true):Number {
        if(_childTween == null)
            return 0;

        if(isInvalid(DURATION))
            validateNow();

        totalTime       = Math.min(_startTime + _childTweenDuration, Math.max(0, totalTime));
        _currentTime    = TweenUtil.roundTime(totalTime);

        _childTween.seek(_currentTime - _startTime - _childTween.delay);

        return _currentTime;
    }

    public function get startTime():Number { return _startTime; }
    public function set startTime(value:Number):void {
        _startTime = TweenUtil.roundTime(value);

        invalidate(START_TIME); // only to dispatch the event
    }

    public function get duration():Number {
        if(isInvalid(DURATION))
            validateNow();

        return _childTweenDuration;
    }

    public function set duration(value:Number):void {
        if(_childTween == null)
            return;

        if(isInvalid(DURATION))
            validateNow();

        var ratio:Number        = TweenUtil.roundTime(value) / _childTweenDuration;

        _childTween.duration    *= ratio;
        _childTween.delay       *= ratio;
        _childTween.repeatDelay *= ratio;

        invalidate(DURATION);
    }

    public function advance(dt:Number):void {
        if(_childTween == null)
            return;

        if(isInvalid(DURATION))
            validateNow();

        dt = TweenUtil.roundTime(dt);

        _currentTime = TweenUtil.roundTime(_currentTime + dt);

        // let it advance for one dt more
        if(_currentTime < _startTime || _currentTime - dt > _startTime + _childTweenDuration)
            return;

        //trace("--- [advanced: " + _currentTime + "] ---");

        _childTween.advance(dt);
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
        _childTween.removeEventListener(ValidationEvent.INVALIDATE, onChildTweenInvalidated);

        _childTween = null;

        super.childRemoved(child);

        invalidate(DURATION);
    }
}
}
