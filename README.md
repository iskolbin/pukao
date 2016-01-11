# pukao
Tiny set of helpers for MOAI SDK. Helpers independent from each other. Helpers don't pollute global namespace. Modules don't try to make MOAI highlevel like Rapanui/Hanappe/Flower frameworks (which is pointless IMHO), they just try to safe some keystrokes:).

## pukao
Allow declarative style of object constructing, i.e. instead of

```
local prop = MOAIProp2D.new()
prop:setLoc( 100, 100 )
prop:setRot( 0.5 )
```

you can write:
```
local prop = pukao.Prop2D{ loc = {100, 100}, rot = 0.5 }
```

## cache
Weak-linked caches for MOAITexture, MOAIGfxQuad2D, MOAIFont. Resources loaded once, assuming they are immutable.
* textures loaded from file ( that's all ): 
```
local texture = cache.Texture'assets/someimage.png'
```
* quads created from texture automatically ( cache.Texture called ):
```
local quad = cache.Quad'assets/someimage.png' -- cache.Texture'assets/someimage.png' is created
```
* fonts created like:
```
local font = cache.Font(path-to-font, font-size, charcodes,[dpi=120])
```
To remove boilerplate of writing charcodes like 'abcdefhijklmopqrstuvwxyz01234567890' you can instead write '::ld' (lowercase letters and digits),another options are:
- **l**, lowercase letters;
- **u**, uppercase letters;
- **d**, digits;
- **a**, letters;
- **w**, alphanumiric;
- **p**, punctuation;
- **s**, special symbols;

## shape
Declarative MOAIScriptDeck for shape drawing, used like:
```
local prop = pukao.Prop2D{ deck = shape.Rect{ 10, 10, fill = {1,0,0}, line = {0,1,0}, penWidth = 2}}
```
will create rectangle filled with red, outlined with green stroke 2-pixel width. 

* **Rect**, width( or first ), height( or second ), fill, line, penWidth;
* **Circle**, radius( or first ), fill, line, penWidth;
* **Ellipse**, radiusX( or first ), radiusY( or second ), fill, line, penWidth;
* **Polygon**, vertices( or table itself ), fill, line, point, penWidth;

