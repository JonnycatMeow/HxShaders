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

//shader version thank you codename engine  
#if (mac||linux||windows)
public var glslVer:String = "120";
#elseif (android||ios) 
public var glslVer:String = "300 es";  
#elseif (web) 
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
            var prefix = '#version ${glslVer}\n';

            @:privateAccess var gl = __context.gl;

			prefix += "#ifdef GL_ES
				"
				+ (precisionHint == FULL ? "#ifdef GL_FRAGMENT_PRECISION_HIGH
				precision highp float;
				#else
				precision mediump float;
				#endif" : "precision lowp float;")
				+ "
				#endif
				";

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
 

	@:noCompletion  override function __processGLData(source:String, storageType:String):Void
        {
            var lastMatch = 0, position, regex, name, type;
    
            if (storageType == "uniform")
            {
                regex = ~/uniform ([A-Za-z0-9]+) ([A-Za-z0-9_]+)/;
            }
            else
            {
                regex = ~/attribute ([A-Za-z0-9]+) ([A-Za-z0-9_]+)/;
            }
    
            while (regex.matchSub(source, lastMatch))
            {
                type = regex.matched(1);
                name = regex.matched(2);
    
                if (StringTools.startsWith(name, "gl_"))
                {
                    return;
                }
    
                var isUniform = (storageType == "uniform");
    
                if (StringTools.startsWith(type, "sampler"))
                {
                    var input = new ShaderInput<BitmapData>();
                    input.name = name;
                    @:privateAccess
                    input.__isUniform = isUniform;
                    __inputBitmapData.push(input);
    
                    switch (name)
                    {
                        case "openfl_Texture":
                            __texture = input;
                        case "bitmap":
                            __bitmap = input;
                        default:
                    }
    
                    Reflect.setField(__data, name, input);
                    try{Reflect.setField(this, name, input);} catch(e) {}
                }
                else if (!Reflect.hasField(__data, name) || Reflect.field(__data, name) == null)
                {
                    var parameterType:ShaderParameterType = switch (type)
                    {
                        case "bool": BOOL;
                        case "double", "float": FLOAT;
                        case "int", "uint": INT;
                        case "bvec2": BOOL2;
                        case "bvec3": BOOL3;
                        case "bvec4": BOOL4;
                        case "ivec2", "uvec2": INT2;
                        case "ivec3", "uvec3": INT3;
                        case "ivec4", "uvec4": INT4;
                        case "vec2", "dvec2": FLOAT2;
                        case "vec3", "dvec3": FLOAT3;
                        case "vec4", "dvec4": FLOAT4;
                        case "mat2", "mat2x2": MATRIX2X2;
                        case "mat2x3": MATRIX2X3;
                        case "mat2x4": MATRIX2X4;
                        case "mat3x2": MATRIX3X2;
                        case "mat3", "mat3x3": MATRIX3X3;
                        case "mat3x4": MATRIX3X4;
                        case "mat4x2": MATRIX4X2;
                        case "mat4x3": MATRIX4X3;
                        case "mat4", "mat4x4": MATRIX4X4;
                        default: null;
                    }
    
                    var length = switch (parameterType)
                    {
                        case BOOL2, INT2, FLOAT2: 2;
                        case BOOL3, INT3, FLOAT3: 3;
                        case BOOL4, INT4, FLOAT4, MATRIX2X2: 4;
                        case MATRIX3X3: 9;
                        case MATRIX4X4: 16;
                        default: 1;
                    }
    
                    var arrayLength = switch (parameterType)
                    {
                        case MATRIX2X2: 2;
                        case MATRIX3X3: 3;
                        case MATRIX4X4: 4;
                        default: 1;
                    }
    
                    switch (parameterType)
                    {
                        case BOOL, BOOL2, BOOL3, BOOL4:
                            var parameter = new ShaderParameter<Bool>();
                            parameter.name = name;
                            @:privateAccess
                            parameter.type = parameterType;
                            @:privateAccess
                            parameter.__arrayLength = arrayLength;
                            @:privateAccess
                            parameter.__isBool = true;
                            @:privateAccess
                            parameter.__isUniform = isUniform;
                            @:privateAccess
                            parameter.__length = length;
                            __paramBool.push(parameter);
    
                            if (name == "openfl_HasColorTransform")
                            {
                                __hasColorTransform = parameter;
                            }
    
                            Reflect.setField(__data, name, parameter);
                            try{Reflect.setField(this, name, parameter);} catch(e) {}
    
                        case INT, INT2, INT3, INT4:
                            var parameter = new ShaderParameter<Int>();
                            parameter.name = name;
                            @:privateAccess
                            parameter.type = parameterType;
                            @:privateAccess
                            parameter.__arrayLength = arrayLength;
                            @:privateAccess
                            parameter.__isInt = true;
                            @:privateAccess
                            parameter.__isUniform = isUniform;
                            @:privateAccess
                            parameter.__length = length;
                            @:privateAccess
                            __paramInt.push(parameter);
                            Reflect.setField(__data, name, parameter);
                            try{Reflect.setField(this, name, parameter);} catch(e) {}
    
                        default:
                            var parameter = new ShaderParameter<Float>();
                            parameter.name = name;
                            @:privateAccess
                            parameter.type = parameterType;
                            @:privateAccess
                            parameter.__arrayLength = arrayLength;
                            #if lime
                            @:privateAccess
                            if (arrayLength > 0) parameter.__uniformMatrix = new Float32Array(arrayLength * arrayLength);
                            #end
                            @:privateAccess
                            parameter.__isFloat = true;
                            @:privateAccess
                            parameter.__isUniform = isUniform;
                            @:privateAccess
                            parameter.__length = length;
                            __paramFloat.push(parameter);
    
                            if (StringTools.startsWith(name, "openfl_"))
                            {
                                switch (name)
                                {
                                    case "openfl_Alpha": __alpha = parameter;
                                    case "openfl_ColorMultiplier": __colorMultiplier = parameter;
                                    case "openfl_ColorOffset": __colorOffset = parameter;
                                    case "openfl_Matrix": __matrix = parameter;
                                    case "openfl_Position": __position = parameter;
                                    case "openfl_TextureCoord": __textureCoord = parameter;
                                    case "openfl_TextureSize": __textureSize = parameter;
                                    default:
                                }
                            }
    
                            Reflect.setField(__data, name, parameter);
                            try{Reflect.setField(this, name, parameter);} catch(e) {}
                    }
                }
    
                position = regex.matchedPos();
                lastMatch = position.pos + position.len;
            }
        }


}
