/**
 * User: booster
 * Date: 8/28/13
 * Time: 14:13
 */
package cadet.components.tweens {
import cadet.components.tweens.ITweenComponent;
import cadet.components.tweens.transitions.ITweenTransition;
import cadet.components.tweens.transitions.TweenTransitions;
import cadet.core.ComponentContainer;
import cadet.events.TweenEvent;
import cadet.util.TweenUtil;

import flash.utils.Dictionary;

public class AbstractTweenComponent extends ComponentContainer implements ITweenComponent {
    protected static const DURATION:String      = "duration";
    protected static const DELAY:String         = "delay";
    protected static const REPEAT_DELAY:String  = "repeatDelay";
    protected static const REPEAT_COUNT:String  = "repeatCount";

    protected var _transition:ITweenTransition  = null; // linear

    protected var _duration:Number              = 1;
    protected var _currentTime:Number           = 0;
    protected var _progress:Number              = 0;
    protected var _delay:Number                 = 0;
    protected var _roundToInt:Boolean           = false;
    protected var _repeatCount:int              = 1;
    protected var _repeatDelay:Number           = 0;
    protected var _repeatReversed:Boolean       = false;
    protected var _reversed:Boolean             = false;
    protected var _currentCycle:int             = -1;

    protected var _listeners:Dictionary         = new Dictionary();

    // cached events
    protected var _startedEvent:TweenEvent;
    protected var _finishedEvent:TweenEvent;
    protected var _advancedEvent:TweenEvent;
    protected var _repeatedEvent:TweenEvent;

    public function AbstractTweenComponent(duration:Number = 1, transition:ITweenTransition = null, name:String = "Tween") {
        super(name);

        _startedEvent   = new TweenEvent(TweenEvent.STARTED, this);
        _finishedEvent  = new TweenEvent(TweenEvent.FINISHED, this);
        _advancedEvent  = new TweenEvent(TweenEvent.ADVANCED, this);
        _repeatedEvent  = new TweenEvent(TweenEvent.REPEATED, this);

        reset(duration, transition);
    }

    // abstract methods

    public function get started():Boolean { throw new UninitializedError("abstract method"); }

    /** The tween will not start, unless this method returns true. */
    protected function isReadyToStart():Boolean { throw new UninitializedError("abstract method"); }

    /** Called before the animation has started. After this method returns, all subsequent calls to 'started' have to return true. */
    protected function animationStarted():void { throw new UninitializedError("abstract method"); }

    /** Called each frame, after internal members have been updated. */
    protected function animationUpdated():void { throw new UninitializedError("abstract method"); }

    // implemented methods

    public function advance(dt:Number):void {
        if(dt == 0)
            return;

        if(! started && ! isReadyToStart())
            return;

        dt = TweenUtil.roundTime(dt);

        // this tween has finished its execution on the previous advance() call
        if((_currentTime == _duration && _currentTime + dt >_duration)
            || (_currentTime == 0 && _currentTime + dt < 0))
            return;

        if(! started) {
            animationStarted();

            if(! started)
                throw new UninitializedError("property 'started' not set to 'true' in the 'animationStarted()' handler");

            if(hasEventListener(TweenEvent.STARTED))
                dispatchEvent(_startedEvent);
        }

        var previousTime:Number     = _currentTime;
        var restTime:Number         = _duration - _currentTime;
        var carryOverTime:Number    = dt > restTime ? dt - restTime : 0.0;

        _currentTime = TweenUtil.roundTime(_currentTime + dt);

        if(_currentTime <= 0)
            return; // the delay is not over yet
        else if(_currentTime > _duration)
            _currentTime = _duration;

        if(_currentCycle < 0 && previousTime <= 0 && _currentTime > 0)
            _currentCycle++;

        _progress = calculateProgress();

        animationUpdated();

        if(hasEventListener(TweenEvent.ADVANCED))
            dispatchEvent(_advancedEvent);

        if(previousTime < _duration && _currentTime >= _duration) {
            if(_repeatCount == 0 || _currentCycle < _repeatCount - 1) {
                _currentTime = -_repeatDelay;
                _currentCycle++;

                if(hasEventListener(TweenEvent.REPEATED))
                    dispatchEvent(_repeatedEvent);
            }
            else {
                // in the 'onComplete' callback, people might want to call "tween.reset" and
                // add it to another juggler; so this event has to be dispatched *before*
                // executing 'onComplete'.
                if(hasEventListener(TweenEvent.FINISHED))
                    dispatchEvent(_finishedEvent);
            }
        }

        if(carryOverTime > 0)
            advance(carryOverTime);
    }

    public function reset(duration:Number = 1, transition:ITweenTransition = null):void {
        _currentTime            = 0.0;
        _duration               = Math.max(0.0001, duration);
        _progress               = 0.0;
        _delay                  = 0.0;
        _repeatDelay            = 0.0;
        _roundToInt             = false;
        _repeatReversed         = false;
        _reversed               = false;
        _repeatCount            = 1;
        _currentCycle           = -1;
        _transition             = transition != null ? transition : TweenTransitions.LINEAR;

        for(var type:String in _listeners) {
            var functions:Vector.<Function> = _listeners[type];

            for each(var func:Function in functions) {
                super.removeEventListener(type, func);
            }

            delete _listeners[type];
        }

        parentComponent = null;
    }

    public function seek(totalTime:Number, suppressEvents:Boolean = true):Number {
        var time:Number = seekImpl(totalTime, suppressEvents);

        animationUpdated();

        return time;
    }

    public function get transition():ITweenTransition { return _transition; }
    public function set transition(value:ITweenTransition):void {
        if(value == null)
            throw new ArgumentError("transition may not be null");

        if(started)
            throw new Error("tween already started, call reset() first");

        _transition = transition;
    }

    public function get duration():Number { return _duration; }
    public function set duration(value:Number):void {
        if(started)
            throw new Error("tween already started, call reset() first");

        _duration = TweenUtil.roundTime(value > 0 ? value : 0);

        invalidate(DURATION);
    }

    public function get currentTime():Number { return _currentTime; }
    public function get progress():Number { return _progress; }

    public function get delay():Number { return _delay; }
    public function set delay(value:Number):void {
        if(started)
            throw new Error("tween already started, call reset() first");

        _currentTime = TweenUtil.roundTime(_currentTime + _delay - value);
        _delay = TweenUtil.roundTime(value > 0 ? value : 0);

        invalidate(DELAY);
    }

    public function get repeatCount():int { return _repeatCount; }
    public function set repeatCount(value:int):void {
        if(started)
            throw new Error("tween already started, call reset() first");

        _repeatCount = value > 0 ? value : 0;

        invalidate(REPEAT_COUNT);
    }

    public function get repeatDelay():Number { return _repeatDelay; }
    public function set repeatDelay(value:Number):void {
        if(started)
            throw new Error("tween already started, call reset() first");

        _repeatDelay = TweenUtil.roundTime(value > 0 ? value : 0);

        invalidate(REPEAT_DELAY);
    }

    public function get repeatReversed():Boolean { return _repeatReversed; }
    public function set repeatReversed(value:Boolean):void {
        if(started)
            throw new Error("tween already started, call reset() first");

        _repeatReversed = value;
    }

    public function get reversed():Boolean { return _reversed; }
    public function set reversed(value:Boolean):void { _reversed = value; }

    public function get roundToInt():Boolean { return _roundToInt; }
    public function set roundToInt(value:Boolean):void {
        if(started)
            throw new Error("tween already started, call reset() first");

        _roundToInt = value;
    }

    override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
        super.addEventListener(type, listener, useCapture, priority, useWeakReference);

        var functions:Vector.<Function> = _listeners[type];

        if(functions == null) {
            functions = new Vector.<Function>();

            _listeners[type] = functions;
        }

        functions.push(listener);
    }

    override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
        super.removeEventListener(type, listener, useCapture);

        var functions:Vector.<Function> = _listeners[type];

        // I guess removing unregistered listener is a valid operation
        if(functions == null)
            return;

        var index:int = functions.indexOf(listener);

        // I guess removing unregistered listener is a valid operation
        if(index == -1)
            return;

        functions.splice(index, 1);
    }

    protected function calculateProgress():Number {
        var ratio:Number    = _currentTime / _duration;
        var revRep:Boolean  = _repeatReversed && (_currentCycle % 2 == 1);
        revRep              = _reversed ? !revRep : revRep;

        if(ratio < 0)       ratio = 0;
        else if(ratio > 1)  ratio = 1;

        return revRep
            ? _transition.value(1.0 - ratio)
            : _transition.value(ratio)
        ;
    }

    protected function seekImpl(totalTime:Number, suppressEvents:Boolean):Number {
        totalTime = Math.min(TweenUtil.totalDuration(this), Math.max(TweenUtil.roundTime(totalTime), -_delay));
        _currentTime = TweenUtil.roundTime(totalTime);
        _currentCycle = _currentTime < 0 ? -1 : 0;

        // normalize time for the current repetition and find the current cycle
        if(_currentTime == _duration) {
            _currentTime = -_repeatDelay;
            _currentCycle = 1;
        }
        else if(_currentTime > _duration) {
            var repeatTime:Number = _repeatDelay + _duration;
            var cycles:Number = _currentTime / repeatTime;
            var reminder:Number = _currentTime % repeatTime;

            _currentCycle = Math.floor(cycles); // current cycle index, starting from 0
            _currentTime = TweenUtil.roundTime(reminder - _repeatDelay);
        }

        _progress = calculateProgress();

        return _currentTime;
    }
}
}
