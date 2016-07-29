--- A camera library for LÖVE with parallax scrolling
-- @author Davis Claiborne
-- @copyright 2016
-- @license MIT

-- TODO:
--  world
--  documentation
--  type checking

local unpack = unpack or table.unpack

-- http://stackoverflow.com/questions/2259476/rotating-a-point-about-another-point-2d
local function rotatePoint( x, y, angle, aboutX, aboutY )
	local sin, cos = math.sin( angle ), math.cos( angle )
	x, y = x - aboutX, y - aboutY
	return x * cos - y * sin + aboutX, x * sin + y * cos + aboutY
end

local function updateDisplayPoints( cam )
	local display = cam.display
	for i = 1, #cam.viewport.points, 2 do
		local x, y = cam:toScreenCoordinates( cam.viewport.points[i], cam.viewport.points[i + 1] )
		cam.display.points[i], cam.display.points[i + 1] = x, y
	end
end

local function getShapeWidthHeight( points )
	local x, y = {}, {}
	for i = 1, #points, 2 do
		table.insert( x, points[i] )
		table.insert( y, points[i + 1] )
	end
	local minX, maxX = math.min( unpack( x ) ), math.max( unpack( x ) )
	local minY, maxY = math.min( unpack( y ) ), math.max( unpack( y ) )

	return maxX - minX, maxY - minY
end

local camera = {
	--- Create a new camera object.
	-- @function camera.new
	-- @tparam number viewportX The top-left corner in reference to the game window
	-- @tparam number viewportY
	-- @tparam number viewportW The dimensions of the camera in reference to the screen
	-- @tparam number viewportH
	-- @treturn cameraObject A table containing the cam:<function> methods
	--
	-- <code>
	--	local Camera = require 'camera'
	--
	--	local cam
	--	function love.load()
	--		-- Create a camera 32 pixels from the top and from the left of the screen
	--		-- That is 32 pixels wide/tall.
	--		cam = Camera( 32, 32, 32, 32 )
	--	end
	-- </code>
	new = function( viewportX, viewportY, viewportW, viewportH )
		local new = {
			-- Data
			viewport = {
				x = viewportX,
				y = viewportY,
				w = viewportW,
				h = viewportH,
				points = {
					viewportX, viewportY,
					viewportX + viewportW, viewportY,
					viewportX + viewportW, viewportY + viewportH,
					viewportX, viewportY + viewportH,
				},
			},
			-- Layers {{{
			addLayer = function( self, name, relativeScaleX, relativeScaleY )
				self.display.layers[name] = {
					push = function( layer, mode )
						-- Don't interfere with colors
						love.graphics.push( mode or 'transform' )
							-- Don't scale/rotate multiple times
							love.graphics.origin()
							love.graphics.translate(
								self.viewport.x + self.display.offsetX,
								self.viewport.y + self.display.offsetY
							)
							love.graphics.rotate( -self.display.rotation )
							love.graphics.scale(
								self.display.scaleX / layer.relativeScaleX,
								self.display.scaleY / layer.relativeScaleY
							)
							love.graphics.translate( -self.display.translationX, -self.display.translationY )
					end,

					pop = function( layer )
						love.graphics.pop()
					end,

					getScale = function( layer )
						return layer.relativeScaleX, layer.relativeScaleY
					end,

					relativeScaleX = relativeScaleX,
					relativeScaleY = relativeScaleY,
				}
				return self.display.layers[name]
			end,

			getLayer = function( self, name )
				return self.display.layers[name]
			end,
			-- }}}
			-- Drawing {{{
			stencilTest = function( self )
				love.graphics.setStencilTest( 'greater', 0 )
			end,

			stencilDrawFunction = function( self )
				love.graphics.polygon( 'fill', unpack( self.viewport.points ) )
			end,

			stencil = function( self )
				love.graphics.stencil( function() self:stencilDrawFunction() end, 'replace', 1 )
				self:stencilTest()
			end,

			setViewportPoints = function( self, ... )
				local points
				if select( '#', ... ) == 1 then points = ...
				else points = { ... } end

				local w, h = getShapeWidthHeight( points )
				print( w, h )
				self.viewport.w, self.viewport.h = w, h
				self.viewport.points = points

				updateDisplayPoints( self )
			end,

			--- Prepare the graphics system for transformations until the pop
			-- @function cam:push
			-- @see cam:pop
			push = function( self, mode )
				self:stencil()
				self:getLayer( 'main' ):push( mode )
			end,

			--- Pops the graphics system to finalize the camera
			-- @function cam:pop
			-- @see cam:push
			pop = function( self )
				self:getLayer( 'main' ):pop()
				love.graphics.setStencilTest()
			end,
			-- }}}
			-- Transformations {{{

			--- Sets the translation of the camera
			-- @function cam:setTranslation
			-- @tparam number translationX
			-- @tparam number translationY
			setTranslation = function( self, translationX, translationY )
				self.display.translationX = translationX
				self.display.translationY = translationY
			end,

			--- Increase the translation of the camera
			-- @function cam:increaseTranslation
			increaseTranslation = function( self, increaseX, increaseY )
				self.display.translationX = self.display.translationX + increaseX
				self.display.translationY = self.display.translationY + increaseY
			end,

			--- Gets the translation of the camera
			-- @function cam:getTranslation
			-- @treturn number translationX
			-- @treturn number translationY
			getTranslation = function( self )
				return self.display.translationX, self.display.translationY
			end,

			--- Sets the rotation of the camera
			-- @function cam:setRotation
			-- @tparam number rotation
			setRotation = function( self, rotation )
				self.display.rotation = rotation
			end,

			--- Increase the rotation of the camera
			-- @function cam:increaseRotation
			increaseRotation = function( self, increase )
				self.display.rotation = self.display.rotation + increase
			end,

			--- Gets the rotation of the camera
			-- @function cam:getRotation
			-- @treturn number rotation
			getRotation = function( self )
				return self.display.rotation
			end,

			--- Sets the scale of the camera
			-- @function cam:setScale
			-- @tparam number scaleX
			-- @tparam number scaleY
			setScale = function( self, scaleX, scaleY )
				self.display.scaleX = scaleX
				self.display.scaleY = scaleY
			end,

			--- Increase the scale of the camera
			-- @function cam:increaseScale
			increaseScale = function( self, increaseX, increaseY )
				self.display.scaleX = self.display.scaleX + increaseX
				self.display.scaleY = self.display.scaleY + increaseY
			end,

			--- Gets the scale of the camera
			-- @function cam:getScale
			-- @treturn number scaleX
			-- @treturn number scaleY
			getScale = function( self )
				return self.display.scaleX, self.display.scaleY
			end,

			--- Convert coordinates from the camera to the screen
			-- @function cam:toScreenCoordinates
			toScreenCoordinates = function( self, x, y, layer )
				layer = layer or 'main'
				local sx, sy = self:getLayer( layer ):getScale()
				-- Translation
				x = x - self.display.offsetX - self.viewport.x
				y = y - self.display.offsetY - self.viewport.y
				-- Rotation
				x, y = rotatePoint( x, y, self.display.rotation, 0, 0 )
				-- Scale
				x = x / ( self.display.scaleX * sx )
				y = y / ( self.display.scaleY * sy )
				-- Final scaling
				x, y = x + self.display.translationX, y + self.display.translationY

				return x, y
			end,
			-- }}}
		}
		-- This table holds the values for new.display, which acts as a proxy table so that
		-- whenever a value is changed the points table is properly updated.
		local display = {
			translationX = 0,
			translationY = 0,
			rotation = 0,
			scaleX = 1,
			scaleY = 1,
			layers = {},
			-- Offset where the camera "looks" (i.e. 0,0 means top-left)
			offsetX = viewportW / 2,
			offsetY = viewportH / 2,
			points = {
				0, 0,
				viewportW, 0,
				viewportW, viewportH,
				0, viewportH,
			}
		}

		new.display = setmetatable( {}, {
			__index = function( _, key )
				return display[key]
			end,
			__newindex = function( _, key, value )
				display[key] = value
				updateDisplayPoints( new )
			end,
		} )

		new:addLayer( 'main', 1, 1 )

		return new
	end,
}

return setmetatable(
	{ new = camera.new },
	{ __call = function( _, ... ) return camera.new( ... ) end }
)
