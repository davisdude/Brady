-- Libraries
Input = require 'Utilities.thomas.Input'
local Class = require 'Utilities.classic.classic'
local Camera = require 'Camera'

local Square = Class:extend( 'Square' )
function Square:new( x, y, width, height )
	self.x = x
	self.y = y
	self.width = width
	self.height = height
end

function Square:draw()
	love.graphics.rectangle( 'fill', self.x, self.y, self.width, self.height )
end

local function drawSquares()
	for _, square in ipairs( Squares ) do
		square:draw()
	end
end

local function checkAABB( px, py, x, y, w, h )
	if px >= x and px <= x + w and py >= y and py <= y + h then
		return true
	end
end

local Close
local Overview
local width

function love.load()
	local function clearSquares()
		Squares = {}
	end
	local function loadMap()
		clearSquares()
		for i = 1, love.math.random( 11, 16 ) do
			table.insert( Squares, Square( love.math.random( -400, 400 ), love.math.random( -300, 300 ), love.math.random( 50, 100 ), love.math.random( 50, 100 ) ) )
		end
	end
	local function setCloseCamera()
		Close = Camera( 64, 64, 400 - 2 * 64, 600 - 2 * 64 )
		Close:setPosition( 400, 300 )

		Background = Close:addLayer( 'Background', .5, .5 )
		Background:setDrawFunction( function()
			love.graphics.setColor( 255, 255, 255, 125 )
			drawSquares()
		end )

		Foreground = Close:addLayer( 'Foreground', 2, 2 )
		Foreground:setDrawFunction( function()
			love.graphics.setColor( 255, 255, 255, 255 )
			drawSquares()
		end )

		Close:getLayer( 'main' ):setDrawFunction( function()
			love.graphics.setColor( 255, 255, 255, 200 )
			drawSquares()
		end )
		
		Close:setWorld( 0, 0, 800, 600 )

		loadMap()
	end

	input = Input()
	input:bind( 'escape', love.event.quit )

	input:bind( 'a', 'moveRight' )
	input:bind( 'd', 'moveLeft' )
	input:bind( 'w', 'moveUp' )
	input:bind( 's', 'moveDown' )
	input:bind( 'q', 'rotateLeft' )
	input:bind( 'e', 'rotateRight' )

	input:bind( 'wheelup', 'zoomIn' )
	input:bind( 'wheeldown', 'zoomOut' )
	input:bind( 'mouse1', 'makeSquare' )

	input:bind( 'o', setCloseCamera ) -- Original
	input:bind( 'u', clearSquares ) -- Undo (all)
	input:bind( 'r', function() clearSquares(); setCloseCamera() end ) -- Reset


	input:bind( 'j', function() Close:setShape( 138, 110, 0, 300, 138, 490, 362, 418, 362, 182 ) end ) 
	input:bind( 'k', function() Close:setShape( 64, 64, 400 - 2 * 64, 600 - 2 * 64 ) end ) 
	input:bind( 'l', function() Close:setShape( 200, 300, 200 ) end ) 

	Overview = Camera( 400, 0, 400, 600 )
	Overview:zoomTo( .25 )
	Overview:setPosition( 400, 300 )

	width = 16
	height = width

	Squares = {}
	setCloseCamera()
end

local function drawMap()
	-- Draw 0, 0
	love.graphics.setColor( 255, 255, 255 )
	love.graphics.circle( 'fill', 0, 0, 5 )
	-- Vertical origin line
	love.graphics.setColor( 255, 0, 0 )
	love.graphics.line( 0, 300, 800, 300 )
	-- Horizontal origin line
	love.graphics.setColor( 0, 0, 255 )
	love.graphics.line( 400, 0, 400, 600 )
	-- Camera bounding box
	love.graphics.setColor( 0, 255, 0 )
	love.graphics.rectangle( 'line', Close:getVisible() )
	-- Actual camera dimensions
	love.graphics.setColor( 125, 125, 125 )
	love.graphics.polygon( 'line', Close:getPoints() )
	-- Center of camera
	love.graphics.setColor( 255, 125, 0 )
	love.graphics.circle( 'fill', Close.x, Close.y, 5 * ( 1 / Close.scaleX ) - 1 )
	-- Draw world boundaries
	love.graphics.setColor( 255, 125, 0 )
	love.graphics.rectangle( 'line', 0, 0, 800, 600 )
	-- Reset Color
	love.graphics.setColor( 255, 255, 255 )
end

function love.update( dt )
	local horizontalMoveSpeed = ( 1 / Close.scaleX ) * 256
	local verticalMoveSpeed = ( 1 / Close.scaleY ) * 256

	Close:adjustScale()
	Close:adjustPosition()

	if input:down( 'moveRight' ) then
		Close:move( -horizontalMoveSpeed * dt, 0 )
	end
	if input:down( 'moveLeft' ) then
		Close:move( horizontalMoveSpeed * dt, 0 )
	end
	if input:down( 'moveUp' ) then
		Close:move( 0, -verticalMoveSpeed * dt )
	end
	if input:down( 'moveDown' ) then
		Close:move( 0, verticalMoveSpeed * dt )
	end
	if input:down( 'rotateLeft' ) then
		Close:rotate( math.pi / 2 * dt )
	end
	if input:down( 'rotateRight' ) then
		Close:rotate( -math.pi / 2 * dt )
	end

	if input:pressed( 'zoomIn' ) then
		Close:zoom( 2 )
	elseif input:pressed( 'zoomOut' ) then
		Close:zoom( 1/2 )
	end

	if input:down( 'makeSquare' ) then
		local mouseX, mouseY = love.mouse.getPosition()
		local x, y, w, h = Close:getVisible()
		cameraMouseX, cameraMouseY = Close:toWorldCoordinates( mouseX, mouseY )
		if checkAABB( cameraMouseX, cameraMouseY, x, y, w, h ) then
			local width, height = ( 1 / Close.scaleX ) * width, ( 1 / Close.scaleY ) * height
			table.insert( Squares, Square( cameraMouseX - ( width / 2 ), cameraMouseY - ( width / 2 ), width, height ) )
		else
			x, y, w, h = Overview:getVisible()
			cameraMouseX, cameraMouseY = Overview:toWorldCoordinates( mouseX, mouseY )
			if checkAABB( cameraMouseX, cameraMouseY, x, y, w, h ) then
				local width, height = ( 1 / Close.scaleX ) * width, ( 1 / Close.scaleY ) * height -- Still use the Close scale
				table.insert( Squares, Square( cameraMouseX - ( width / 2 ), cameraMouseY - ( width / 2 ), width, height ) )
			end
		end
	end

	input:update( dt )
end

function love.draw()
	Close:draw()

	Overview:push()
		drawMap()
		drawSquares()
	Overview:pop()

	love.graphics.setColor( 0, 255, 0 )
	love.graphics.print( love.mouse.getX() .. ', ' .. love.mouse.getY(), 2, 2 )
end

function love.keypressed( key, isRepeat )
	input:keypressed( key )
end

function love.keyreleased( key, isRepeat )
	input:keyreleased( key )
end

function love.mousepressed( x, y, button )
	input:mousepressed( button )
end

function love.mousereleased( x, y, button )
	input:mousereleased( button )
end

function love.gamepadpressed( joystick, button )
	input:gamepadpressed( joystick, button )
end

function love.gamepadreleased( joystick, button )
	input:gamepadreleased( joystick, button )
end

function love.gamepadaxis( joystick, axis, value )
	input:gamepadaxis( joystick, axis, value )
end

function love.quit()
end
