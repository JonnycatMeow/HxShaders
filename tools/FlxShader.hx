package; 
import openfl.display3D.Program3D;
import flixel.system.FlxAssets.FlxShader as OriginalFlxShader;
import flixel.graphics.tile.FlxGraphicsShader; 
import openfl.display.BitmapData;
import openfl.display.ShaderParameter;
import openfl.display.ShaderParameterType;
import openfl.display.ShaderInput;
import lime.utils.Float32Array; 
import openfl.display.GraphicsShader; 
using StringTools;

class FlxShader extends OriginalFlxShader  
{  

#if (mac||linux||windows)
public var glslVer:String = "120";
#else
public var glslVer:String = "100"; 
#end  
@:noCompletion override function __initGL():Void
    {
        if (__glSourceDirty || __paramBool == null)
        {
            __glSourceDirty = false;
            program = null;

            __inputBitmapData = new Array();
            __paramBool = new Array();
            __paramFloat = new Array();
            __paramInt = new Array();

            __processGLData(glVertexSource, "attribute");
            __processGLData(glVertexSource, "uniform");
            __processGLData(glFragmentSource, "uniform");
        }

        if (__context != null && program == null)
        {

            @:privateAccess var gl = __context.gl;

			#if (mac||linux||windows)
                        var prefix = "#ifdef GL_ES\n" 
                                + '#version ${glslVer}\n'
				+ (precisionHint == FULL ? "#ifdef GL_FRAGMENT_PRECISION_HIGH
				precision highp float;
				#else
				precision mediump float;
				#endif\n" : "precision lowp float;\n")
				+ "#endif\n";
                        #else
                        var prefix = '#version ${glslVer}\n' 
                                + "#ifdef GL_ES\n"
				+ (precisionHint == FULL ? "#ifdef GL_FRAGMENT_PRECISION_HIGH
				precision highp float;
				#else
				precision mediump float;
				#endif\n" : "precision lowp float;\n")
				+ "#endif\n";
                        #end

			var vertex = prefix + glVertexSource;
			var fragment = prefix + glFragmentSource;

			var id = vertex + fragment;
            @:privateAccess 
			if (__context.__programs.exists(id))
			{
				@:privateAccess program = __context.__programs.get(id);
			}
			else
			{
				program = __context.createProgram(GLSL);

				@:privateAccess program.__glProgram = __createGLProgram(vertex, fragment);

				@:privateAccess __context.__programs.set(id, program);
			}

			if (program != null)
			{
				@:privateAccess glProgram = program.__glProgram;

				for (input in __inputBitmapData)
				{
                    @:privateAccess 
					if (input.__isUniform)
					{
						@:privateAccess input.index = gl.getUniformLocation(glProgram, input.name);
					}
					else
					{
						@:privateAccess input.index = gl.getAttribLocation(glProgram, input.name);
					}
				}

				for (parameter in __paramBool)
				{
                    @:privateAccess 
					if (parameter.__isUniform)
					{
						@:privateAccess parameter.index = gl.getUniformLocation(glProgram, parameter.name);
					}
					else
					{
						@:privateAccess parameter.index = gl.getAttribLocation(glProgram, parameter.name);
					}
				}

				for (parameter in __paramFloat)
				{
                    @:privateAccess 
					if (parameter.__isUniform)
					{
						@:privateAccess parameter.index = gl.getUniformLocation(glProgram, parameter.name);
					}
					else
					{
						@:privateAccess parameter.index = gl.getAttribLocation(glProgram, parameter.name);
					}
				}

				for (parameter in __paramInt)
				{
                    @:privateAccess 
					if (parameter.__isUniform)
					{
                        @:privateAccess 
						parameter.index = gl.getUniformLocation(glProgram, parameter.name);
					}
					else
					{
                        @:privateAccess 
						parameter.index = gl.getAttribLocation(glProgram, parameter.name);
					}
				}
			}
        }
    }

}
