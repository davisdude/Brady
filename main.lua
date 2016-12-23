local Camera = require 'camera'

local offset = 32
local W, H = love.graphics.getDimensions()

local function resizeCamera( self, w, h )
	local scaleW, scaleH = w / self.w, h / self.h
	local scale = math.min( scaleW, scaleH )
	self.w, self.h = scale * self.w, scale * self.h
	self.aspectRatio = self.w / w
	self.offsetX, self.offsetY = self.w / 2, self.h / 2
	offset = offset * scale
end

local function drawCameraBounds( cam, mode )
	love.graphics.rectangle( mode, cam.x, cam.y, cam.w, cam.h )
end

local mobileCam = Camera( W / 2 - 2 * offset, H - 2 * offset, { x = offset, y = offset, resizable = true, maintainAspectRatio = true,
	resizingFunction = function( self, w, h )
		resizeCamera( self, w, h )
		local W, H = love.graphics.getDimensions()
		self.x = offset
		self.y = offset
	end,
	getContainerDimensions = function()
		local W, H = love.graphics.getDimensions()
		return W / 2 - 2 * offset, H - 2 * offset
	end
} )

-- Moves at the same speed as the main layer
close = mobileCam:addLayer( 'close', 2, { relativeScale = .5 } )
far = mobileCam:addLayer( 'far', .5 )

local overviewCam = Camera( W / 2 - 2 * offset, H - 2 * offset, { x = W / 2 + offset, y = offset, resizable = true, maintainAspectRatio = true,
	resizingFunction = function( self, w, h )
		resizeCamera( self, w, h )
		local W, H = love.graphics.getDimensions()
		self.x = W / 2 + offset
		self.y = offset
	end,
	getContainerDimensions = function()
		local W, H = love.graphics.getDimensions()
		return W / 2 - 2 * offset, H - 2 * offset
	end
} )

local squares = {}
local function newSquare( x, y, w, h )
	table.insert( squares, {
		x = x - w / 2, y = y - h / 2,
		w = w, h = h,
		draw = function( self )
			love.graphics.rectangle( 'fill', self.x, self.y, self.w, self.h )
		end,
	} )
end

local function drawSquares()
	for _, square in ipairs( squares ) do square:draw() end
end

function love.load()
end

function love.update( dt )
	local moveSpeed = 300 / mobileCam.scale

	-- Proves that toWorldCoordinates and toScreenCoordinates are accurate
	-- Floating points may cause this to be _almost_ the same
	-- local x, y = love.mouse.getPosition()
	-- local _x, _y = mobileCam:toScreenCoordinates( mobileCam:toWorldCoordinates( x, y ) )
	-- assert( x == _x and y == _y, x .. '~=' .. _x .. ', ' .. y .. '~=' .. _y )

	if love.keyboard.isDown( 'q' ) then mobileCam:rotate( math.pi * dt ) end
	if love.keyboard.isDown( 'e' ) then mobileCam:rotate( -math.pi * dt ) end
	if love.keyboard.isDown( 'w' ) then mobileCam:translate( 0, -moveSpeed * dt ) end
	if love.keyboard.isDown( 's' ) then mobileCam:translate( 0, moveSpeed * dt ) end
	if love.keyboard.isDown( 'a' ) then mobileCam:translate( -moveSpeed * dt, 0 ) end
	if love.keyboard.isDown( 'd' ) then mobileCam:translate( moveSpeed * dt, 0 ) end

	if love.mouse.isDown( 1 ) then
		local x, y = love.mouse.getPosition()
		if  x > mobileCam.x and x < mobileCam.x + mobileCam.w
		and y > mobileCam.y and y < mobileCam.y + mobileCam.h then
			local newX, newY = mobileCam:toWorldCoordinates( x, y )
			newSquare( newX, newY, offset / mobileCam.scale, offset / mobileCam.scale )
		end
		if  x > overviewCam.x and x < overviewCam.x + overviewCam.w
		and y > overviewCam.y and y < overviewCam.y + overviewCam.h then
			local newX, newY = overviewCam:toWorldCoordinates( x, y )
			newSquare( newX, newY, offset / mobileCam.scale, offset / mobileCam.scale )
		end
	end

	mobileCam:update()
	overviewCam:update()
end

function love.draw()
	drawCameraBounds( mobileCam, 'line' )
	drawCameraBounds( overviewCam, 'line' )

	-- Keep squares from bleeding
	love.graphics.stencil( function() drawCameraBounds( mobileCam, 'fill' ) end, 'replace', 1 )
	love.graphics.setStencilTest( 'greater', 0 )
	mobileCam:push()
		far:push()
			love.graphics.setColor( 255, 0, 0, 25 )
			drawSquares()
		far:pop()

		love.graphics.setColor( 0, 255, 0, 255 )
		drawSquares()

		-- Either method is acceptable
		mobileCam:push( 'close' )
			love.graphics.setColor( 0, 0, 255, 25 )
			drawSquares()
		mobileCam:pop( 'close' )
	mobileCam:pop()

	love.graphics.setColor( 255, 255, 255 )
	love.graphics.stencil( function() drawCameraBounds( overviewCam, 'fill' ) end, 'replace', 1 )
	love.graphics.setStencilTest( 'greater', 0 )
	overviewCam:push()
		drawSquares()
	overviewCam:pop()

	love.graphics.setStencilTest()
end

function love.keyreleased( key )
	if key == 'escape' then love.event.quit()
	elseif key == 'c' then squares = {}
	elseif key == 'o' then
		mobileCam:setTranslation( 0, 0 )
		mobileCam:setRotation( 0, 0 )
		mobileCam:setScale( 1 )
	elseif key == 'r' then
		love.keyreleased( 'o' )
		love.keyreleased( 'c' )
	end
end

function love.wheelmoved( dx, dy )
	if dy > 0 then mobileCam:scaleBy( 2 ) end
	if dy < 0 then mobileCam:scaleBy( .5 ) end
end
