Brady
===

Brady is a camera library for [LOVE] that features parallax scrolling and aspect ratios.

Minimal Example
---

Below is a minimal example of using the module. In the repository, you will find a more advanced example/demo [here](#demo)

```lua
local Camera = require 'Camera'

function love.load()
	-- Create a camera with a 'width' of 400 x 300 on screen at ( 32, 32 ).
	-- Because the camera has the flags 'resizable' and 'maintainAspectRatio', the default scaling will take over
	-- So everything drawn will be scaled up to maximize space within the window, with a 32 pixel buffer from each edge.
	cam = Camera( 400, 300, { x = 32, y = 32, resizable = true, maintainAspectRatio = true } )
end

function love.update( dt )
	cam:update() -- Needed to appropriately resize the camera
end

function love.draw()
	cam:push()
		-- By default, translation is half camera width, half camera height
		-- So this draws a rectangle at the center of the screen.
		love.graphics.rectangle( 'fill', -32, -32, 64, 64 )
	cam:pop()
end
```

Demo
---

Within the repo is a demo to show off some of the capabilities. To run, follow the instructions found [here](https://love2d.org/wiki/Game_Distribution#Create_a_.love-file). In the demo, the left box shows a close-up view, the right box shows an overview. Use the mouse to create squares using either box. With the mousewheel you can zoom in and out and you can move around using the `wasd` keys and rotate with `q` and `e`. To reset the view, press `o` (for origin). To clear the squares, press `c`, and to reset everything, press `r`.

Gotchas
---

- Every camera has a layer called `'main'` automatically created. This layer has the same scale as the camera and is used simply to distinguish the layers.
- Layers can have an attribute known as the "relativeScale". This value is used to control how fast the layer moves, relative to its scale. For instance, if the layer has a scale of 2 and a relativeScale of .5, it will move at the same speed as the main layer, but will appear twice as large. See [cam:addLayer](#camaddlayer) for more.
- `cam.scale` is a number, __not__ a function. Use [cam:scaleBy](#camscaleby) instead.

Functions
---

### Camera.newCamera

Creates a new camera object.

__Synopsis__: `cam = Camera.newCamera( w, h, flags )` or `cam = Camera( w, h, flags )`

- `cam`: Table. A new camera object.
- `w, h`: Numbers. The width/height of the camera. If the flags `resizable` and `maintainAspectRatio` are set, these are used to determine the scaling needed. Otherwise, it sets the camera to this size.
- `flags`: Table. These allow you to set some of the options of the camera without using getter/setter methods. Possible flags are:

	- `x, y`: _Numbers_ (Default to `0, 0`). The position of the camera on the screen.
	- `translationX, translationY`: _Numbers_ (Defaults to `0, 0`). The translation of the camera.
	- `offsetX, offsetY`: _Numbers_ (Default to `w / 2, h / 2`). The amount to offset the camera.
	- `scale`: _Number_ (Defaults to `1`). The scale of the camera.
	- `rotation`: _Number_ (Defaults to `0`). The rotation of the camera.
	- `resizable`: _Boolean_ (Defaults to `false`). `true` if the camera can be resized, `false` if it cannot.
	- `maintainAspectRatio`: _Boolean_ (Defaults to `false`). `true` if the initial aspect ratio should be maintained, false if it shouldn't.
	- `center`: _Boolean_ (Defaults to `false`). `true` if offsets should be centered on a screen, false if it shouldn't.
	- `mode`: _String_ (Defaults to `'transform'`). The [StackType] to use for `push`ing and `pop`ing the camera.
	- `update`: _Function_. The function called every frame used to control scaling and size. By default, if the camera is resizable, the resizing function is called, passing itself and the results of `cam:getContainerDimensions`.
	- `resizingFunction`: _Function_. Only called if the `resizable` flag is true. Used to set the width and height of the camera, as well as any other changes due to resizing. By default, the function changes the `aspectRatioScale`, `offsetX` and `offsetY`, `w`, and `h` of the camera and takes the parameters `self`, `containerW`, and `containerH`.
	- `getContainerDimensions`: _Function_. By default, it returns the width and height of the screen.

### cam:push

Prepare the draw area. Pseudonym for [layer:push](#layer-push).

__Synopsis__: `cam:push( layer )`

- `layer`: `nil`, _String_, or _table_ (Defaults to `'main'`, a layer that is automatically created). The name of the layer (as specified in [cam:addLayer](#camaddlayer)) __or__ the layer, as returned by [cam:addLayer](#camaddlayer).

### cam:pop

Used to stop the camera scaling, etc. Pseudonym for [layer:pop](#layer-pop).

__Synopsis__: `cam:pop( layer )`

- `layer`: `nil`, _String_, or _table_. See [cam:push](#campush) for a detailed description of the layer. By default, this is just the same as calling [love.graphics.pop](#https://love2d.org/wiki/love.graphics.pop), so specifying the layer isn't required unless you want to for stylistic reasons.

### cam:getWorldCoordinates

Returns the position within the "world," i.e. what the camera is seeing. Translates mouse coordinates to in-game coordinates.

__Synopsis__: `worldX, worldY = cam:getWorldCoordinates( screenX, screenY )`

- `worldX, worldY`: _Numbers_. The word-coordinates of the mouse.
- `screenX, screenY`: _Numbers_. The coordinates on-screen, i.e. the mouse usually.

### cam:getScreenCoordinates

Translates in-game coordinates to the screen. The opposite of [cam:getWorldCoordinates](#camtoworldcoordinates).

__Synopsis__: `screenX, screenY = cam:getWorldCoordinates( worldX, worldY )`

- `screenX, screenY`: _Numbers_. The coordinates on-screen, i.e. the mouse usually.
- `worldX, worldY`: _Numbers_. The word-coordinates of the mouse.

### cam:getMouseWorldCoordinates

Short for `cam:getScreenCoordinates( love.mouse.getPosition() )`. See [cam:getScreenCoordinates](#camtoscreencoordinates) for more.

__Synopsis__: `screenX, screenY = cam:getMouseWorldCoordinates( layer )`

- `screenX, screenY`: _Numbers_. The coordinates on-screen, i.e. the mouse usually.
- `layer`: `nil`, _String_, or _table_. See [cam:push](#campush) for a detailed description of the layer. If `nil`, the main layer is used.

### cam:setViewportPosition

Set the x and y position of the camera's upper-left corner on-screen. Wrapper function for `cam.x, cam.y = -- etc`.

__Synopsis__: `cam:setViewportPosition( x, y )`

- `x, y`: _Numbers_. The upper-left corner of the camera.

### cam:getViewportPosition

Returns the upper-left x and y position of the camera.

__Synopsis__: `x, y = cam:getViewportPosition()`

- `x, y`: _Numbers_. The upper-left corner of the camera.

### cam:setOffset

Sets the camera's offset, which, by default, is `w / 2` and `h / 2`.

__Synopsis__: `cam:setOffset( x, y )`

- `x, y`: _Numbers_. The x and y offset for the camera.

### cam:setTranslation

Gets the camera's offset.

__Synopsis__: `x, y = cam:getOffset()`

- `x, y`: _Numbers_. The x and y offset of the camera.

### cam:getTranslation

### cam:increaseTranslation

Get/set/increase the translation.

### cam:translate

Synonymous with [cam:increaseTranslation](#camincreasetranslation)

### cam:setRotation

### cam:getRotation

### cam:increaseRotation

Get/set/increase the rotation.

### cam:rotate

Synonymous with [cam:increaseRotation](#camincreaseRotation)

### cam:setScale

### cam:getScale

### cam:increaseScale

Get/set/increase the scale.

### cam:scaleBy

Increase the scale by a factor.

__Synopsis__: `cam:scaleBy( factor )`

- `factor`: _Number_. Multiply the scale by this amount. e.g. if the scale is .5 and you `scaleBy` 2, the scale is now 1.

### cam:increaseScaleToPoint

Increment the scale, while zooming in to a point

__Synopsis__: `cam:increaseScaleToPoint( ds, wx, wy )`

- `ds`: _Number_. The amount by which to increment the scale. I.e. if `scale` is _1_ and `ds` is _.1_, then new scale is _1.1_.
- `wx, wy`: `nil` or _Numbers_. The __world__ coordinates to zoom into. If left `nil`, defaults to [`cam:getMouseWorldCoordinates()`](#camgetmouseworldcoordinates).

### cam:scaleToPoint

Increase the scale by a factor, while zooming to a point

__Synopsis__: `cam:scaleToPoint( s, wx, wy )`

- `s`: _Number_. The factor by which to increase the scale. I.e. if `scale` is _1_ and `s` is _2_, the new scale is _2_. 
- `wx, wy`: `nil` or _Numbers_. The _world_ coordinates to zoom into. If left `nil`, defaults to [`cam:getMouseWorldCoordinates()`](#camgetmouseworldcoordinates).

### cam:getLayer

Get the specified layer.

__Synopsis__: `layer = cam:getLayer( target )`

- `target`: _Table_ or _String_. Get the specified layer. If a table is passed, the table is returned. If a string is passed, the layer of the specified name is returned.
- `layer`: _Table_ or `nil`. The specified layer, or `nil` if the specified layer does not exist.

### cam:addLayer

Create a new layer for the camera.

__Synopsis__: `layer = cam:addLayer( name, scale, flags )`

- `name`: _String_. The name used to identify the layer.
- `scale`: _Number_. The scale of the layer.
- `flags`: _Table_. These allow you to specify values for the layer. Possible flags are:

	- `relativeScale`: _Number_ (Defaults to `1`). The relative scale of the layer. This does __not__ affect the scale in any way; this controls how much the layer is translated. For instance, a layer with a scale of 2 and a relative scale of .5 moves at the same speed as the main layer, it is just twice the size.
	- `mode`: _String_ (Defaults to `cam.mode`). The [StackType] of the layer.

### layer:push

Prepare for the layer's translations.

__Synopsis__: `layer:push()`

### layer:pop

Ends the layer's translations. By default, it's only [love.graphics.pop].

__Synopsis__: `layer:pop()`

[LOVE]: https://love2d.org
[StackType]: https://love2d.org/wiki/StackType
[love.graphcis.pop]: https://love2d.org/wiki/love.graphics.pop

License
---

This is under the MIT license, which can be found at the top of [camera.lua](/camera.lua)
