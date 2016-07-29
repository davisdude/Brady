local Camera = require 'camera'
local Square = require 'Square'

local cam, foreground, background
local overview
local _W, _H
local squares = {}
local font = love.graphics.getFont()
local fontW, fontH = font:getWidth( 'a' ), font:getHeight( 'a' )

local function checkAABB( px, py, x, y, w, h )
	if px >= x and px <= x + w and py >= y and py <= y + h then
		return true
	end
	return false
end

local function sign( x )
	return math.abs( x ) / x
end

local offset = 32
local function setup()
	-- Main camera
	cam = Camera( offset, offset, _W / 2 - offset * 2, _H - offset * 2 )
	cam:setTranslation( 0, 0 )
	cam.moveSpeed = 256
	cam.rotationSpeed = cam.moveSpeed / 32
	-- Layers
	foreground = cam:addLayer( 'foreground', .5, .5 )
	background = cam:addLayer( 'background', 2, 2 )

	-- Overview
	overview = Camera( _W / 2 + offset, offset, _W / 2 - offset * 2, _H - offset * 2 )
	overview:setTranslation( 0, 0 )
	overview:setScale( .25, .25 )

	-- Compass
	compass = Camera( _W / 2 - offset, _H / 2 - offset, offset * 2, offset * 2 )
	compass:setTranslation( 0, 0 )
end

local function draw()
	for _, v in ipairs( squares ) do
		v:draw()
	end
end

function love.load()
	_W, _H = love.graphics.getDimensions()
	setup()
end

function love.draw()
	-- cam
	love.graphics.polygon( 'line', unpack( cam.viewport.points ) )
	cam:push( 'all' )
		-- Layers don't strictly HAVE to be drawn within their respective camera's draw
		-- But if they aren't the stencil doesn't apply to them
		background:push( 'all' )
			love.graphics.setColor( 0, 0, 255, 50 )
			draw()
		background:pop()

		-- This is drawn at whatever scale the camera is at
		love.graphics.setColor( 0, 255, 0, 255 )
		draw()

		foreground:push( 'all' )
			love.graphics.setColor( 255, 0, 0, 50 )
			draw()
		foreground:pop()
	cam:pop()

	-- overview
	love.graphics.polygon( 'line', unpack( overview.viewport.points ) )
	overview:push()
		draw()
		love.graphics.polygon( 'line', unpack( cam.display.points ) )
	overview:pop()

	-- compass
	love.graphics.polygon( 'line', unpack( compass.viewport.points ) )
	compass:push()
		love.graphics.line( 0, 2 * offset / 3, 0, -2 * offset / 3 )
		love.graphics.line( 2 * offset / 3, 0, -2 * offset / 3, 0 )
		love.graphics.print( 'w', -fontW / 2, -2 * offset / 3 - fontH )
		love.graphics.print( 's', -fontW / 2, 2 * offset / 3 )
		love.graphics.print( 'a', -2 * offset / 3 - fontW, -fontH / 2 )
		love.graphics.print( 'd', 2 * offset / 3, -fontH / 2 )
	compass:pop()
end

function love.update( dt )
	compass:setRotation( cam:getRotation() )

	local moveSpeed = cam.moveSpeed / cam.display.scaleX
	if love.keyboard.isDown( 'a' ) then cam:increaseTranslation( -moveSpeed * dt, 0 ) end
	if love.keyboard.isDown( 'd' ) then cam:increaseTranslation( moveSpeed * dt, 0 ) end
	if love.keyboard.isDown( 'w' ) then cam:increaseTranslation( 0, -moveSpeed * dt ) end
	if love.keyboard.isDown( 's' ) then cam:increaseTranslation( 0, moveSpeed * dt ) end
	if love.keyboard.isDown( 'q' ) then cam:increaseRotation( -cam.rotationSpeed * dt ) end
	if love.keyboard.isDown( 'e' ) then cam:increaseRotation( cam.rotationSpeed * dt ) end

	if love.mouse.isDown( 1 ) then
		local x, y = love.mouse.getPosition()
		local w, h = 32, 32
		-- If you wanted to get fancy here you would include the proper check depending on
		-- camera shape (i.e. pointInPolygon, etc.)
		if checkAABB( x, y, cam.viewport.x, cam.viewport.y, cam.viewport.w, cam.viewport.h ) then
			w, h = w / cam.display.scaleX, h / cam.display.scaleY
			x, y = cam:toScreenCoordinates( x, y )
			table.insert( squares, Square( x - w / 2, y - h / 2, w, h ) )
		elseif checkAABB( x, y, overview.viewport.x, overview.viewport.y, overview.viewport.w, overview.viewport.h ) then
			x, y = overview:toScreenCoordinates( x, y )
			table.insert( squares, Square( x - w / 2, y - h / 2, w, h ) )
		end
	end
end

function love.keyreleased( key )
	if key == 'escape' then
		love.event.quit()
	elseif key == 'o' then
		setup()
	elseif key == 'c' then
		squares = {}
	elseif key == 'r' then
		setup()
		squares = {}
	elseif key == 'j' then
		cam:setViewportPoints( 138, 110, 0, 300, 138, 490, 362, 418, 362, 182 )
		cam.display.offsetX, cam.display.offsetY = cam.viewport.w / 2, cam.viewport.h / 2
	end
end

function love.wheelmoved( dx, dy )
	local sx0, sy0 = cam:getScale()
	local dt = love.timer.getDelta()
	dy = dt * sign( dy )
	cam:increaseScale( dy, dy )
	local sx1, sy1 = cam:getScale()
	if sx1 < 0 then cam:setScale( sx0, sy0 ) end
end
