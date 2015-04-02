--[[
	To-Do:
		- Make center same independent of shape
]]

local unpack = unpack or table.unpack

local function err( errCode, passed, ... )
	local types = { ... }
	local typeOfPassed = type( passed )
	if type( types[1] ) == 'function' then
		assert( types[1]( passed ), errCode:gsub( '%%type%%', typeOfPassed ) )
		return true
	end
	local passed = false
	for i = 1, #types do
		if types[i] == typeOfPassed then
			passed = true
			break
		end
	end
	errCode = errCode:gsub( '%%type%%', typeOfPassed )
	assert( passed, 'Camera Error: ' .. errCode )
end

-- Stolen from http://stackoverflow.com/questions/2259476/rotating-a-point-about-another-point-2d
local function rotateAboutPoint( pointX, pointY, angle, x, y )
	local sin = math.sin( angle )
	local cos = math.cos( angle )

	x = x - pointX
	y = y - pointY

	local newX = x * cos - y * sin
	local newY = x * sin + y * cos

	return newX + pointX, newY + pointY
end

local function getActualCameraPosition( self )
	local cameraX = self.x - ( self.offsetX / self.scaleX )
	local cameraY = self.y - ( self.offsetY / self.scaleY )
	return cameraX, cameraY
end

local function getCameraPoints( self )
	local x, y = getActualCameraPosition( self )
	local width, height = self.width / self.scaleX, self.height / self.scaleY
	local x1, y1, x2, y2, x3, y3, x4, y4 = x, y, x + width, y, x + width, y + height, x, y + height

	local centerX, centerY = x + self.offsetX / self.scaleX, y + self.offsetY / self.scaleY
	x1, y1 = rotateAboutPoint( centerX, centerY, -self.rotation, x1, y1 )
	x2, y2 = rotateAboutPoint( centerX, centerY, -self.rotation, x2, y2 )
	x3, y3 = rotateAboutPoint( centerX, centerY, -self.rotation, x3, y3 )
	x4, y4 = rotateAboutPoint( centerX, centerY, -self.rotation, x4, y4 )
	
	return x1, y1, x2, y2, x3, y3, x4, y4
end

local Camera = {}
Camera.__index = Camera

function Camera.new( x, y, width, height )
	err( 'new: Expected a number for x, the first argument. Got %type%.', x, 'number' )
	err( 'new: Expected a number for y, the first argument. Got %type%.', y, 'number' )
	err( 'new: Expected a number for width, the first argument. Got %type%.', width, 'number' )
	err( 'new: Expected a number for height, the first argument. Got %type%.', height, 'number' )

	local new = {
		x = 0, y = 0,
		screenX = x, screenY = y,
		width = width, height = height,
		scaleX = 1, scaleY = 1,
		offsetX = width / 2, offsetY = height / 2,
		rotation = 0,
		drawStencil = function( self )
			love.graphics.rectangle( 'fill', self.screenX, self.screenY, self.width, self.height )
		end, 
		shape = {}, -- Use these for custom screen shapes
		layers = {}, 
	}

	setmetatable( new, Camera )
	new:addLayer( 'main', 1, 1 ) -- Main layer

	return new
end

function Camera:addLayer( name, scale )
	err( 'addLayer: Layer name must be string or number, got %type%.', name, 'string', 'number' )
	err( 'addLayer: Layer scale must be number, got %type%.', scale, 'number' )
	
	self.layers[name] = {
		push = function( layer )
			love.graphics.push( 'transform' ) -- Shouldn't interfere
				love.graphics.origin() -- Prevent scaling and zooming and etc multiple times
				love.graphics.translate( self.offsetX + self.screenX, self.offsetY + self.screenY ) -- Allow for rotation and zooming to occur from center of screen
				love.graphics.rotate( self.rotation )
				love.graphics.scale( self.scaleX * layer.relativeScale, self.scaleY * layer.relativeScale )
				love.graphics.translate( -self.offsetX - self.screenX, -self.offsetY - self.screenY ) -- Move zoom and rotation back to normal for drawing.
	
				love.graphics.translate( self.offsetX + self.screenX, self.offsetY + self.screenY )
				love.graphics.translate( -self.x, -self.y )
		end, 
		pop = function( layer )
			love.graphics.pop()
		end, 
		setRelativeScale = function( layer, scale )
			layer.relativeScale = scale
		end, 
		getRelativeScale = function( layer )
			return layer.relativeScale
		end, 
		relativeScale = scale, 
	}

	return self.layers[name]
end

function Camera:push()
	love.graphics.setStencil( function() self:drawStencil() end ) 
	self:getLayer( 'main' ):push()
end

function Camera:pop()
	self:getLayer( 'main' ):pop()
	love.graphics.setStencil() -- Set back to default
end

function Camera:getLayer( name )
	err( 'getLayer: Expected string or number, got %type%.', name, 'string', 'number' )
	return self.layers[name]
end

function Camera:getLayers()
	return self.layers
end

function Camera:move( distanceX, distanceY )
	self.x = self.x + ( distanceX or 0 ) 
	self.y = self.y + ( distanceY or 0 ) 
end

function Camera:moveTo( x, y )
	self.x = x or 0
	self.y = y or 0
end

function Camera:zoom( xFactor, yFactor )
	self.scaleX = self.scaleX * ( xFactor or 1 )
	self.scaleY = yFactor and self.scaleY * yFactor or self.scaleX
end

function Camera:zoomTo( scaleX, scaleY )
	self.scaleX = scaleX or 1
	self.scaleY = scaleY or scaleX
end

function Camera:increaseZoom( xFactor, yFactor ) -- This is to allow more easy zooming using dt
	err( 'increaseZoom: Expected number for the x-factor, got %type%.', xFactor, 'number' )
	self.scaleX = self.scaleX + xFactor
	self.scaleY = yFactor and self.scaleY + yFactor or self.scaleX
end

function Camera:rotate( amount )
	err( 'rotate: Expected number, got %type%.', amount, 'number' )
	self.rotation = self.rotation + amount
end

function Camera:rotateTo( rotation )
	err( 'rotateTo: Expected number, got %type%.', rotation, 'number' )
	self.rotation = rotation or 0
end

function Camera:getWindow()
	return self.screenX, self.screenY, self.width, self.height
end

function Camera:getVisible()
	local x1, y1, x2, y2, x3, y3, x4, y4 = getCameraPoints( self )

	local lowestX = math.min( x1, x2, x3, x4 )
	local largestX = math.max( x1, x2, x3, x4 )
	local lowestY = math.min( y1, y2, y3, y4 )
	local largestY = math.max( y1, y2, y3, y4 )

	local width, height = largestX - lowestX, largestY - lowestY

	return lowestX, lowestY, width, height
end

function Camera:toWorldCoordinates( x, y, layer )
	layer = layer or 'main'
	err( 'toWorldCoordiantes: x must be number, got %%type%%.', x, 'number' )
	err( 'toWorldCoordinates: y must be number, got %%type%%.', y, 'number' )
	err( 'toWorldCoordinates: layer name should be string or number, got %type%.', layer, 'string', 'number' )
	err( 'toWorldCoordinates: layer "' .. layer .. '" not registered.', layer, function( t ) return self.layers[t] end )

	local multiple = self.layers[layer]:getRelativeScale()
	-- Get actual camera x and y
	local cameraX, cameraY = getActualCameraPosition( self )
	-- Get scaled distance from mouse to screen
	local distanceX = ( x - self.screenX ) / ( self.scaleX * multiple )
	local distanceY = ( y - self.screenY ) / ( self.scaleY * multiple )
	-- Add scaled distance to camera
	x = cameraX + distanceX
	y = cameraY + distanceY
	-- Rotate
	x, y = rotateAboutPoint( self.x, self.y, -self.rotation, x, y )
	
	return x, y
end

function Camera:toScreenCoordinates( x, y, layer ) 
	layer = layer or 'main'
	err( 'toScreenCoordinates: x must be number, got %%type%%.', x, 'number' )
	err( 'toScreenCoordinates: y must be number, got %%type%%.', y, 'number' )
	err( 'toScreenCoordinates: layer name should be string or number, got %type%.', layer, 'string', 'number' )
	err( 'toScreenCoordinates: layer "' .. layer .. '" not registered.', layer, function( t ) return self.layers[t] end )
	
	local multiple = self.layers[layer]:getRelativeScale()
	-- Get actual Camera x and y
	local cameraX, cameraY = getActualCameraPosition( self )
	-- Rotate
	x, y = rotateAboutPoint( self.x, self.y, self.rotation, x, y )
	-- Get scaled distance from to screen
	local distanceX = ( x + self.screenX ) / ( self.scaleX * multiple )
	local distanceY = ( y + self.screenY ) / ( self.scaleY * multiple )
	-- Subtract scaled distance from camera
	x = ( distanceX - cameraX ) * self.scaleX
	y = ( distanceY - cameraY ) * self.scaleY
	
	return x, y
end

function Camera:getPoints()
	return getCameraPoints( self )
end

function Camera:getStencil()
	return self.drawStencil
end

function Camera:setStencil( func )
	err( 'setStencil: Expected function, got %type%.', func, 'function' )
	self.drawStencil = func
end

function Camera:getShape()
	return self.shape
end

function Camera:setShape( ... ) 
	-- TODO: Make it automatically set center of new camera to center of old camera?
	local points = {}
	if type( ... ) == 'table' then points = ... else points = { ... } end
	for i = 1, #points do
		err( 'setShape: Expected an array of numbers, element ' .. i .. ' was %type%.', points[i], 'number' )
	end
	local centerX, centerY = self.x, self.y

	if #points == 3 then
		self:setStencil( function() love.graphics.circle( 'fill', points[1], points[2], points[3] ) end )
		self.width, self.height = points[3] * 2, points[3] * 2
		self.offsetX, self.offsetY = points[3], points[3]
		self.screenX, self.screenY = points[1] - points[3], points[2] - points[3]
		self:setPosition( centerX, centerY )
	elseif #points == 4 then
		self:setStencil( function() love.graphics.rectangle( 'fill', points[1], points[2], points[3], points[4] ) end )
		self.width, self.height = points[3], points[4]
		self.offsetX, self.offsetY = self.width / 2, self.height / 2
		self.screenX, self.screenY = points[1], points[2]
		self:setPosition( centerX, centerY )
	elseif #points % 2 == 0 then
		local triangles = love.math.triangulate( points )
		-- Triangulation prevents problems with complex polygons
		self:setStencil(
			function()
				for i = 1, #triangles do
					love.graphics.polygon( 'fill', triangles[i] )
				end
			end
		)
		local x, y = {}, {}
		for i = 1, #points, 2 do
			local index = .5 * i + .5
			x[index] = points[i]
			y[index] = points[i + 1]
		end
		self.width = math.max( unpack( x ) ) - math.min( unpack( x ) )
		self.height = math.max( unpack( y ) ) - math.min( unpack( y ) )
		self.offsetX, self.offsetY = self.width / 2, self.height / 2
		self.screenX, self.screenY = math.min( unpack( x ) ), math.min( unpack( y ) )
		self:setPosition( centerX, centerY )
	else
		error( string.format( 'Camera Error: setShape- expected 3, 4, or an even number of points, got %s.' ), #points )
	end
end

-- Aliases
Camera.setPosition = Camera.moveTo
Camera.setZoom = Camera.zoomTo
Camera.setRotation = Camera.rotateTo
Camera.setCenter = Camera.setPosition

return setmetatable( Camera,
	{
		__call = function( _, ... )
			return Camera.new( ... )
		end
	}
)
