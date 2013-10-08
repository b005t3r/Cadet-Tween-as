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

    protected var _animatedProperties:String    = ""; // JSON string

    public function TweenComponent(target:IComponent = null, duration:Number = 1, transition:ITweenTransition = null, name:String = "Tween") {
        super(duration, transition, name);

        this.target = target;
    }

    /** The target component that is animated. */
    public function get target():IComponent { return _target; }
    [Serializable][Inspectable(editor="ComponentList", scope="scene", priority="50")]
    public function set target(value:IComponent):void {
        if(started)
            throw new Error("tween already started, call reset() first");

        _target = value;
    }

    /** Animate given property from current to given value. */
    public function animateTo(propertyName:String, value:Number):void {
        animateFromTo(propertyName, Number.NaN, value);
    }

    /** Animate given property from given to current value. */
    public function animateFrom(propertyName:String, value:Number):void {
        animateFromTo(propertyName, value, Number.NaN);
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

    public function get animatedProperties():String {
        return _animatedProperties;
    }

    [Serializable][Inspectable(priority="51")]
    public function set animatedProperties(value:String):void {
        parseAnimatedProperties(value);
        _animatedProperties = createAnimatedProperties();
    }

    protected function createAnimatedProperties():String {
        var propArray:Array = [];

        var count:int = _properties.length;
        for(var i:int = 0; i < count; i++) {
            var name:String = _properties[i];
            var start:Number = _startValues[i];
            var end:Number = _endValues[i];

            var obj:Object;

            if(start == start) { // !isNaN
                if(end == end) // !isNan
                    obj = { "name" : name, "from" : start, "to" : end };
                else
                    obj = { "name" : name, "from" : start};
            }
            else {
                obj = { "name" : name, "to" : end };
            }

            propArray[i] = obj;
        }

        return JSON.stringify(propArray);
    }

    protected function parseAnimatedProperties(value:String):void {
        var propArray:Array = null;

        var jsonObj:Object = JSON.parse(value);
        propArray = Array(jsonObj);

        // hack, I have no idea why is it wrapped in another array
        if(propArray.length == 1 && propArray[0] is Array)
            propArray = propArray[0];

        _properties.length = 0;
        _startValues.length = 0;
        _endValues.length = 0;

        for each (var obj:Object in propArray) {
            if(! obj.hasOwnProperty("name"))
                throw new TypeError("animated property has no name");

            var hasFrom:Boolean = obj.hasOwnProperty("from");
            var hasTo:Boolean   = obj.hasOwnProperty("to");

            if(hasFrom) {
                if(hasTo)
                    animateFromTo(obj["name"], obj["from"], obj["to"]);
                else
                    animateFrom(obj["name"], obj["from"]);
            }
            else if(hasTo) {
                animateTo(obj["name"], obj["to"]);
            }
            else {
                throw new TypeError("animated property \'" + obj["name"] + "\' has no 'from' nor 'to' value");
            }
        }
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

        _animatedProperties = createAnimatedProperties();

        delete _invalidationTable[PROPERTIES];
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

    override protected function animationFinished():void {
        _started = false;
    }
}
}
