# pukao
Tiny set of helpers for MOAI SDK. Helpers independent from each other. Helpers don't pollute global namespace. Modules don't try to make MOAI highlevel like Rapanui/Hanappe/Flower frameworks (which is pointless IMHO), they just try to safe some keystrokes and make code more declarative.

## Moai
Allow declarative style of object constructing, i.e. instead of

```
local prop = MOAIProp2D.new()
prop:setLoc( 100, 100 )
prop:setRot( 0.5 )
```

you can write:
```
local prop = Moai.Prop2D{ loc = {100, 100}, rot = 0.5 }
```

special field: **_**, i.e. private args, table which copies to object fields without changes. Also you can specify second argument in constuctor which overrides **_** args. Example:
```
local prop = Moai.Prop2D({ _ = {arg1 = 2, arg2 = 3}}, {arg2 = 4} )
print( prop.arg1 ) -- 2
print( prop.arg2 ) -- 4
```

## Cache
Weak-linked caches for MOAITexture, MOAIGfxQuad2D, MOAIFont. Resources loaded once, assuming they are immutable.
* textures loaded from file ( that's all ): 
```
local texture = Cache.Texture'assets/someimage.png'
```
* quads created from texture automatically ( cache.Texture called ):
```
local quad = Cache.Quad'assets/someimage.png' -- cache.Texture'assets/someimage.png' is created
```
* fonts created like:
```
local font = Cache.Font(path-to-font, font-size, charcodes,[dpi=120])
```
To remove boilerplate of writing charcodes like 'abcdefhijklmopqrstuvwxyz01234567890' you can instead write '::ld' (lowercase letters and digits),another options are:
- **l**, lowercase letters;
- **u**, uppercase letters;
- **d**, digits;
- **a**, letters;
- **w**, alphanumiric;
- **p**, punctuation;
- **s**, special symbols;

## Shape
Declarative MOAIScriptDeck for shape drawing, used like:
```
local prop = Moai.Prop2D{ deck = Shape.rect{ 10, 10, fill = {1,0,0}, line = {0,1,0,width = 2}}}
```
will create rectangle filled with red, outlined with green stroke 2-pixel width. 

* **Rect**, width( or first ), height( or second ), fill, line;
* **Circle**, radius( or first ), fill, line, penWidth;
* **Ellipse**, radiusX( or first ), radiusY( or second ), fill, line;
* **Polygon**, vertices( or table itself ), fill, line, point;

note that **line** and **point** can have **width** parameter ( 1 by default ).

## Touch
Simple common touch/mouse input handling. To use:
```
local Touch = require'Touch'
Touch:install()
```
Now MOAIDeviceMgr.device.touch + pointer + mouseLeft/Right/Middle callbacks set. When you touch somewhere or click layers will be taken using MOAIRenderMgr.getRenderTable(). If layer set **passive** property it's ignored. Touch event propagated from top to bottom for all props in the layer which hit by click/touch. If entitites has event handlers they are called. Events:

* **onTouchDown( self, touchobj, x, y, idx )**
* **onTouchUp( self, touchobj, x, y, idx )**
* **onTouchMove( self, touchobj, x, y, idx )**

Where **touchobj** is global object containing all current taps. For mouse users there are constants for **idx**:

* **Touch.LEFT**
* **Touch.RIGHT**
* **Touch.MIDDLE**
