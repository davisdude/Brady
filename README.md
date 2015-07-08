Brady
====

A camera library with parallax scrolling for LÖVE. 

#Table of Contents
- [Usage](#usage)
- [Name](#name)
- [Functions](#functions)
	- [Camera.new](#cameranew)
	- [Camera:push](#camerapush)
	- [Camera:pop](#camerapop)
	- [Camera:draw](#cameradraw)
	- [Camera:setWorld](#camerasetworld)
	- [World Functions](#world-functions)
		- [Camera:adjustscale](#cameraadjustscale)
		- [Camera:adjustposition](#cameraadjustposition)
	- [Camera:addLayer](#cameraaddlayer)
	- [Camera:getLayer](#cameragetlayer)
	- [Layer](#layers)
		- [Layer:push](#layerpush)
		- [Layer:pop](#layerpop)
		- [Layer:setRelativeScale](#layersetrelativescale)
		- [Layer:getRelativeScale](#layergetrelativescale)
		- [Layer:setDrawFunction](#layersetdrawfunction)
		- [Layer:getDrawFunction](#layergetdrawfunction)
	- [Camera:move](#cameramove)
	- [Camera:moveTo](#cameramoveto)
	- [Camera:zoom](#camerazoom)
	- [Camera:zoomTo](#camerazoomto)
	- [Camera:increaseZoom](#cameraincreasezoom)
	- [Camera:rotate](#camerarotate)
	- [Camera:getWindow](#cameragetwindow)
	- [Camera:getVisible](#cameragetvisible)
	- [Camera:toWorldCoordinates](#cameratoworldcoordinates)
	- [Camera:toScreenCoordinates](#cameratoscreencoordinates)
	- [Camera:getPoints](#cameragetpoints)
	- [Camera:getStencil](#cameragetstencil)
	- [Camera:setStencil](#camerasetstencil)
	- [Camera:getShape](#cameragetshape)
	- [Camera:setShape](#camerasetshape)
	- [Aliases](#aliases)
- [Examples](#examples)
- [License](#license)

##Usage
```Lua
local Camera = require 'Path.to.camera'

function love.load()
	Cam = Camera.new( 64, 64, 800 - 64 * 2, 600 - 64 * 2 )
	-- This creates a camera that appears on the screen's x and y of 64, 64 and is 800 - 64 * 2 width, and etc.
	Cam:setPosition( 400, 300 ) -- This sets the camera's center at 400, 600.
end

local function drawWorld()
	love.graphics.rectangle( 'fill', 32, 32, 32, 32 )
end

function love.load()
	Cam:push()
		drawWorld()
	Cam:pop()
end
```
And that's it! 

##Name
- Brady is named after Matthew Brady, famous American Civil War photographer. I thought it would be fitting if the camera library would be named after a famous person who used a camera.

##Functions
###Camera.new
- Creates a new camera object.
- Synopsis:
	- `Cam = Camera.new( screenX, screenY, width, height )`
	- `Cam = Camera( screenX, screenY, width, height )`
- Arguments: 
	- `screenX`, `screenY`: Numbers. The x and y coordinates for where the camera will be on the screen.
	- `width`, `height`: Numbers. The width and height of the camera at the scale of 1, as well as the size it occupies on the screen.
- Returns: 
	- `Cam`: Table. A camera object.
- Notes: 
	- By default, the camera has one layer: main. This layer is automatically drawn and done by default and acts just like any other layer.

###Camera:push
- Push the graphics to prepare for the camera.
- Synopses:
	- `Camera.push( Cam )`
	- `Cam:push()`
- Arguments: 
	- `Cam`: Table. A camera object returned by [Camera.new](#cameranew).
- Returns: 
	- Nothing.

###Camera:pop
- Pops the graphics to close-out the camera.
- Synopses: 
	- `Camera.pop( Cam )`
	- `Cam:pop()`
- Arguments: 
	- `Cam`: Table. A camera object returned by [Camera.new](#cameranew).
- Returns
	- Nothing.

###Camera:draw
- Adds manual z-ordering so you don't have to worry about it.
- Synopses:
	- `Camera.draw( Cam )`
	- `Cam:draw()`
- Arguments: 
	- `Cam`: Table. A camera object returned by [Camera.new](#cameranew).
- Returns: 
	- Nothing.

###Camera:setWorld
- Set world boundaries (AABB) required for certain functions.
- Synopses:
	- `World = Camera.setWorld( Cam, x, y, width, height )`
	- `World = Cam:setWorld( x, y, width, height )`
- Arguments: 
	- `Cam`: Table. A camera object returned by [Camera.new](#cameranew).
	- `x`, `y`: Numbers. The top left x and y coordinates for the world.
	- `width`, `height`: Numbers. The width and height of the world. 
- Returns: 
	- `World`: Table. A table with the world's information (`{ x = x, y, = y, width = width, height = height }`)

###World Functions
- These functions require a world to be set using [Camera:setWorld](#camerasetworld).

#####Camera:adjustScale
- Put this inside of love.update in order to keep the camera scaled within the world coordinates. This does __not__ acount for position, for that see [Camera:adjustPosition](#cameraadjustposition).
- Synopses:
	- `Camera.adjustScale( Cam )`
	- `Cam:adjustScale()`
- Arguments: 
	- `Cam`: Table. A camera object returned by [Camera.new](#cameranew).
- Returns: 
	- Nothing.

#####Camera:adjustPosition
- Put this inside of love.update in order to keep the camera positioned within the world (i.e. you can't see outside of the world boundaries). This does __not__ account for scaling (and frankly, doesn't really work without bound-scaling), for that, see [Camera:adjustScale](#cameraadjustscale).
- Synopses:
	- `Camera.adjustPosition( Cam )`
	- `Cam:adjustPosition()`
- Arguments: 
	- `Cam`: Table. A camera object returned by [Camera.new](#cameranew).
- Returns: 
	- Nothing.

###Camera:addLayer
- Adds a layer to the camera. Layers are used for parallax scrolling.
- Synopses: 
	- `Layer = Camera.addLayer( Cam, name, scale )`
	- `Layer = Cam:addLayer( name, scale )`
- Arguments: 
	- `Cam`: Table. A camera object returned by [Camera.new](#cameranew).
	- `name`: String. The name the camera will be referred to by.
	- `scale`: Number. The amount by which you increase/decrease the scale.
- Returns: 
	- Layer`: Table. The layer information that is drawn.
```Lua
layer = Cam:addLayer( 'testLayer', .5 )

-- Drawing
layer:push()
	...
layer:pop()
```

###Camera:getLayer
- Get the layer of a camera given the name.
- Synopses: 
	- `Layer = Camera.getLayer( Cam, name )`
	- `Layer = Cam:getLayer( name )`
- Arguments: 
	- `Cam`: Table. A camera object returned by [Camera.new](#cameranew).
	- `name`: String. The name passed in [Camera:addLayer](#cameraaddlayer).
- Returns
	- `Layer`: Table. A layer object also returned when created by [Camera:addLayer](#cameraaddlayer).

###Layers
- These are used for parallax scrolling. By default, a layer called `'main'` is created with relative scale of 1. This is actually where things not in other layers are drawn.

#####Layer:push
- Similar to [Camera:push](#camerapush), but acts as the push for the layer.
- Synopses:
	- `Layer.push( Layer )`
	- `Layer:push()`
- Arguments: 
	- `layer`: Table. A layer object returned by [Camera:addLayer](#cameraaddlayer) or [Camera:getLayer](#cameragetlayer).
- Returns:
	- Nothing.

#####Layer:pop
- Similar to [Camera:pop](#camerapop), but acts as the pop for the layer.
- Synopses:
	- `Layer.pop( Layer )`
	- `Layer:pop()`
- Arguments: 
	- `Layer`: Table. A layer object returned by [Camera:addLayer](#cameraaddlayer) or [Camera:getLayer](#cameragetlayer).
- Returns:
	- Nothing.

#####Layer:setRelativeScale
- Sets the amount that the layer is scaled by. For example, 2 would make everything larger.
- Synopses:
	- `Layer.setRelativeScale( Layer, scale )`
	- `Layer:setRelativeScale( scale )`
- Arguments: 
	- `Layer`: Table. A layer object returned by [Camera:addLayer](#cameraaddlayer) or [Camera:getLayer](#cameragetlayer).
	- `scale`: Number. The amount by which the layer should increase the scaling.
- Returns:
	- Nothing.

#####Layer:getRelativeScale
- Gets the amount that the layer is scaled by.
- Synopses:
	- `relativeScale = Layer.getRelativeScale( Layer )`
	- `relativeScale = Layer:getRelativeScale()`
- Arguments: 
	- `Layer`: Table. A layer object returned by [Camera:addLayer](#cameraaddlayer) or [Camera:getLayer](#cameragetlayer).
- Returns:
	- `relativeScale`: Number. The relative scale of the layer.

#####Layer:setDrawFunction
- Sets the draw function to be used if you're using [Camera:draw](#cameradraw).
- Synopses:
	- `Layer.setDrawFunction( Layer, func )`
	- `Layer:push( func )`
- Arguments: 
	- `Layer`: Table. A layer object returned by [Camera:addLayer](#cameraaddlayer) or [Camera:getLayer](#cameragetlayer).
	- `func`: Function. The function that is called when being drawn.
- Returns:
	- Nothing.

#####Layer:getDrawFunction
- Gets the draw function used by [Camera:draw](#cameradraw).
- Synopses:
	- `drawFunction = Layer.getDrawFunction( Layer )`
	- `drawFunction = Layer:getDrawFunction()`
- Arguments: 
	- `Layer`: Table. A layer object returned by [Camera:addLayer](#cameraaddlayer) or [Camera:getLayer](#cameragetlayer).
- Returns:
	- `drawFunction`: Function. The function used by [Camera:draw].

###Camera:move
- Move the camera by a certain amount.
- Synopses:
	- `Camera.move( Cam, distanceX, distanceY )`
	- `Cam:move( distanceX, distanceY )`
- Arguments:
	- `Cam`: Table. A camera object returned by [Camera.new](#cameranew).
	- `distanceX`, `distanceY`: Numbers. The distance to move the camera horizontally and vertically.
- Returns: 
	- Nothing.

###Camera:moveTo
- Move the camera's __center__ to a specific point.
- Synopses:
	- `Camera.moveTo( Cam, [x, y] )`
	- `Cam:moveTo( [x, y] )`
- Arguments:
	- `Cam`: Table. A camera object returned by [Camera.new](#cameranew).
	- `x`, `y`: Number. The center position for the camera. Defaults as 0, 0.

###Camera:zoom
- Zooms the camera (increases/decreases the scale).
- Synopses: 
	- `Camera:zoom( Cam, [xFactor, yFactor] )`
	- `Cam:zoom( [xFactor, yFactor] )`
- Arguments: 
	- `Cam`: Table. A camera object returned by [Camera.new](#cameranew).
	- `xFactor`: Numbers. The amount by which to increase the horizontal scale. Defaults as 1.
	- `yFactor`: Numbers. The amount by which to increase the vertical scale. Defaults as `xFactor`.
- Returns:
	- Nothing.
- Notes:
	- To clarify, this means if you have the scale at 2, 2 and to `Cam:zoom( 4, 4 )`, the scale becomes 8, 8.

###Camera:zoomTo
- Sets the camera's zoom.
- Synopses: 
	- `Camera.zoomTo( Cam, [scaleX, scaleY] )`
	- `Cam:zoomTo( [scaleX, scaleY] )`
- Arguments: 
	- `Cam`: Table. A camera object returned by [Camera.new](#cameranew).
	- `scaleX`: Number. The horizontal scale. Defaults to 1.
	- `scaleY`: Number. The vertical scale. Defaults to `scaleX`.
- Returns:
	- Nothing.

###Camera:increaseZoom
- Increase/decrease the zoom by a certain amount. Useful for smooth zooming using `dt`.
- Synopses: 
	- `Camera.increaseZoom( Cam, xFactor, [yFactor] )`
	- `Cam:increaseZoom( xFactor, [yFactor] )`
- Arguments: 
	- `Cam`: Table. A camera object returned by [Camera.new](#cameranew).
	- `xFactor`: Number. The amount by which to increase the horizontal scale.
	- `yFactir`: Number. The amount by which to increase the vertical scale. Defaults to `xFactor`.
- Returns:
	- Nothing.

###Camera:rotate
- Increase the rotation by a certain amount.
- Synopses: 
	- `Camera.rotate( Cam, rotation )`
	- `Cam:rotate( rotation )`
- Arguments: 
	- `Cam`: Table. A camera object returned by [Camera.new](#cameranew).
	- `rotation`: Number. The amount by which to increase the rotation.
- Returns:
	- Nothing.

###Camera:rotateTo
- Set the rotation of the camera.
- Synopses: 
	- `Camera.rotateTo( Cam, rotation )`
	- `Cam:rotateTo( rotation )`
- Arguments: 
	- `Cam`: Table. A camera object returned by [Camera.new](#cameranew).
	- `rotation`: Number. The number (in radians) to set the rotation of the camera to.
- Returns:
	- Nothing.

###Camera:getWindow
- Returns the screen location (window) of the camera.
- Synopses: 
	- `Camera.getWindow( Cam )`
	- `Cam:getWindow`
- Arguments: 
	- `Cam`: Table. A camera object returned by [Camera.new](#cameranew).
- Returns:
	- `x`, `y`: Numbers. The x and y location of the camera on the screen.
	- `width`, `height`: Numbers. The width and height of the camera on the screen.

###Camera:getVisible
- Returns the location of the camera within the world.
- Synopses: 
	- `Camera.getVisible( Cam )`
	- `Cam:getVisible()`
- Arguments: 
	- `Cam`: Table. A camera object returned by [Camera.new](#cameranew).
- Returns:
	- `x`, `y`:` Numbers. The x and y location of the camera within the world.
	- `width`, `height`: Numbers. The width and height of the camera within the world (this __does__ account for scaling).

###Camera:toWorldCoordinates
- Convert screen coordinates to the location within the world (from the Camera's perspective).
- Synopses: 
	- `Camera.toWorldCoordinates( Cam, x, y, [layer] )`
	- `Cam:toWorldCoordinates( x, y, [layer] )`
- Arguments: 
	- `Cam`: Table. A camera object returned by [Camera.new](#cameranew).
	- `x`, `y`: Numbers. The screen x and y coordinates to be converted to the world.
	- `layer`: String. The name passed by [Camera.addLayer](#cameraaddlayer). Defaults to `'main'`.
- Returns:
	- `x`, `y`: Numbers. The x and y locations to the world.

###Camera:toScreenCoordinates
- Convert world coordinates to the location on the screen.
- Synopses: 
	- `Camera.toScreenCoordinates( Cam, x, y, [layer] )`
	- `Cam:toScreenCoordinates( x, y, [layer] )`
- Arguments: 
	- `Cam`: Table. A camera object returned by [Camera.new](#cameranew).
	- `x`, `y`: Numbers. The x and y screen coordinates.
	- `layer`: String. The name passed by [Camera.addLayer](#cameraaddlayer). Defaults to `'main'`.
- Returns:
	- `x`, `y`: Nubmers. The x and y locations from the world to the screen.

###Camera:getPoints
- Get the points of the camera. 
- Synopses: 
	- `Camera.getPoints( Cam )`
	- `Cam:getPoints()`
- Arguments: 
	- `Cam`: Table. A camera object returned by [Camera.new](#cameranew).
- Returns:
	- `x1`, `y1`, `x2`, `y2`, `x3`, `y3`, `x4`, `y4`: Numbers. The points of the camera.

###Camera:getStencil
- Get the stencil for drawing the camera.
- Synopses: 
	- `Camera.getStencil( Cam )`
	- `Cam:getStencil()`
- Arguments: 
	- `Cam`: Table. A camera object returned by [Camera.new](#cameranew).
- Returns:
	- `stencil`: Function. The drawing function for the camera.

###Camera:setStencil
- Set the stencil for drawing the camera.
- Synopses: 
	- `Camera.setStencil( Cam, func )`
	- `Cam:setStencil( func )`
- Arguments: 
	- `Cam`: Table. A camera object returned by [Camera.new](#cameranew).
	- `func`: Function. The function for drawing the camera.
- Returns:
	- Nothing.

###Camera:getShape
- Get the shape of the camera.
- Synopses: 
	- `Camera.getShape( Cam )`
	- `Cam:getShape()`
- Arguments: 
	- `Cam`: Table. A camera object returned by [Camera.new](#cameranew).
- Returns:
	- `points`: Table. The points for drawing the camera's shape.
		- 3 points means the camera is circular (x, y, r).
		- 4 points means the camera is a rectangle (x, y, w, h).
		- Even number > 5 means the camera is a polygon (x1, y1, x2, y2, ...).

###Camera:setShape
- Set the shape of the camera.
- Synopses: 
	- `Camera.setShape( Cam, points )`
	- `Cam:setShape( ... )`
- Arguments: 
	- `Cam`: Table. A camera object returned by [Camera.new](#cameranew).
	- `points`: Table. A table containing the points to be used for drawing the camera.
		- 3 points means the camera is circular (x, y, r).
		- 4 points means the camera is a rectangle (x, y, w, h).
		- Even number > 5 means the camera is a polygon (x1, y1, x2, y2, ...).
- Returns:
	- Nothing.

###Aliases
- These functions are also available, and work just like their counterpart.

| Alias			| Corresponding Function		|
| -------------	|:-----------------------------:|
| setPosition	| [moveTo](#cameramoveto)		|
| setCenter		| [moveTo](#cameramoveto)		|
| setZoom		| [zoomTo](#camerazoomto)		|
| setRotation	| [rotateTo](#camerarotateto)	|

##Examples
See [Examples](https://github.com/davisdude/Brady/tree/master/Examples/).

##License
A camera library with parallax scrolling for LÖVE.
Copyright (C) 2015 Davis Claiborne
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
Contact me at davisclaib at gmail.com
