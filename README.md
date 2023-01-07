#  hxShaders

how to apply it to your Friday Night Funkin Mod with shaders 

1. install hmm  
``` 
haxelib install hmm 
``` 
2. install the haxelib
```
haxelib git hxShaders https://github.com/JonnycatMeow/hxShaders.git
```
3. Paste this in your project.xml 
```
<haxelib name="hxShaders"/>  
``` 
4. Remove the code that says  import flixel.system.FlxAssets.FlxShader; and replace it with 
```
import FlxShader;
``` 

# Credits
- [YoshiCrafter29](https://github.com/YoshiCrafter29) -  For making the FlxShader.
- [Jobf](https://github.com/jobf) -  For making the FlxShadertoy.
- [MasterEric](https://github.com/MasterEric) -  For making the FlxRuntimeShader.

# How to tell which version of opengl is supported? 

install glview on mac app store to see if the version is compatibile
