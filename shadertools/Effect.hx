package shadertools; 
import shadertools.FlxShader;  
//this helps stable the Flxfixedshaders code
class Effect {
	function setValue(shader:FlxShader, variable:String, value:Float){
		Reflect.setProperty(Reflect.getProperty(shader, 'variable'), 'value', [value]);
	}
	
}
