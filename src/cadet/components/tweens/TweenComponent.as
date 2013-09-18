/**
 * User: booster
 * Date: 8/28/13
 * Time: 14:39
 */

package cadet.components.tweens {

import cadet.components.tweens.transitions.CompoundTransition;
import cadet.components.tweens.transitions.ITweenTransition;
import cadet.core.IComponent;

public class TweenComponent extends AbstractTweenComponent {
    protected static const PROPERTIES:String    = "properties";

    protected var _target:IComponent            = null;

    protected var _started:Boolean              = false;

    protected var _properties:Vector.<String>   = new Vector.<String>();
    protected var _startValues:Vector.<Number>  = new Vector.<Number>();
    protected var _endValues:Vector.<Number>    = new Vector.<Number>();

    public function TweenComponent(target:IComponent = null, duration:Number = 1, transition:ITweenTransition = null, name:String = "Tween") {
        super(duration, transition, name);

        this.target = target;
    }

    /** The target component that is animated. */
    public function get target():IComponent { return _target; }
    public function set target(value:IComponent):void {
        if(started)
            throw new Error("tween already started, call reset() first");

        _target = value;
    }

    /** Animate given property from current to given value. */
    public function animateTo(propertyName:String, value:Number):void {
        animateFromTo(propertyName, valueFrom(propertyName), value);
    }

    /** Animate given property from given to current value. */
    public function animateFrom(propertyName:String, value:Number):void {
        animateFromTo(propertyName, value, valueTo(propertyName));
    }

    /** Animate given property from and to given value. */
    public function animateFromTo(propertyName:String, from:Number, to:Number):void {
        var index:int = _properties.indexOf(propertyName);

        if(index == -1) {
            _properties.push(propertyName);
            _startValues.push(from);
            _endValues.push(to);
        }
        else {
            _startValues[index] = from;
            _endValues[index]   = to;
        }

        invalidate(PROPERTIES);
    }

    /** Names of the properties animated using this tween. */
    public function get propertyNames():Vector.<String> { return _properties; }

    /** Start value for given property (or NaN if not set). */
    public function valueFrom(propertyName:String):Number {
        var index:int = _properties.indexOf(propertyName);

        return index == -1
            ? Number.NaN
            : _startValues[index]
        ;
    }

    /** End value for given property (or NaN if not set). */
    public function valueTo(propertyName:String):Number {
        var index:int = _properties.indexOf(propertyName);

        return index == -1
            ? Number.NaN
            : _endValues[index]
        ;
    }

    /** Fills in missing start and end values. */
    public function validateProperties():void {
        var numProperties:int = _properties.length;
        for(var i:int = 0; i < numProperties; ++i) {
            if(_startValues[i] != _startValues[i]) // isNaN check - "isNaN" causes allocation!
                _startValues[i] = _target[_properties[i]] as Number;

            if(_endValues[i] != _endValues[i]) // isNaN check - "isNaN" causes allocation!
                _endValues[i] = _target[_properties[i]] as Number;
        }

        invalidate(PROPERTIES);
    }

    override public function reset(duration:Number = 1, transition:ITweenTransition = null):void {
        _started            = false;
        _target             = null;
        _properties.length  = 0;
        _startValues.length = 0;
        _endValues.length   = 0;

        super.reset(duration, transition);
    }

    override public function get started():Boolean { return _started; }

    override protected function validate():void {
        if(isInvalid(PROPERTIES))
            validateProperties();

        super.validate();
    }

    override protected function isReadyToStart():Boolean {
        return _target != null;
    }

    override protected function animationStarted(reversed:Boolean):void {
        _started = true;

        // setup start and end values
        if(! isInvalid(PROPERTIES))
            validateProperties();
    }

    override protected function animationUpdated(parentTransition:CompoundTransition):void {
        var numProperties:int = _properties.length;

        for(var i:int = 0; i < numProperties; ++i) {
            var startValue:Number   = _startValues[i];
            var endValue:Number     = _endValues[i];
            var delta:Number        = endValue - startValue;
            var currentValue:Number = startValue + _progress * delta;

            if(_roundToInt)
                currentValue = Math.round(currentValue);

            _target[_properties[i]] = currentValue;
        }
    }
}
}
