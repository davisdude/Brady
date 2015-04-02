local Utilities = {}


Utilities.hasCanvas = love.graphics.isSupported( 'canvas' )
Utilities.hasPo2 = love.graphics.isSupported( 'npot' )
Utilities.screenWidth = love.graphics.getWidth()
Utilities.sreenHeight = love.graphics.getHeight()

function Utilities.trimTailingSpaces( str ) -- Removes extra spaces from the end of a word. 
	return ( str:gsub( '^%s*(.-)%s*$', '%1' ) )
end

function Utilities.setToCanvas( width, height, func ) -- Sets a picture to canvas, handling Po2 problems. 
	if not Utilities.hasCanvas then return false end
	if not Utilities.hasPo2 then
		width, height = Utilities.formatPo2( width ), Utilities.formatPo2( height )
	end
	local canvas = love.graphics.newCanvas( width, height )
	love.graphics.setCanvas( canvas )
		func()
	love.graphics.setCanvas()
	
	return Canvas
end

function Utilities.formatPo2( goal ) -- Makes numbers Po2 compatible. 
	local number = 1
	while goal < number do
		number = number * 2
	end
	
	return number
end

function Utilities.deepCopy( tab, cache ) -- Makes a deep copy of a table. 
    if type( tab ) ~= 'table' then
        return tab
    end

    cache = cache or {}
    if cache[tab] then
        return cache[tab]
    end

    local new = {}
    cache[tab] = new
    for key, value in pairs( tab ) do
        new[Utilities.deepCopy( key, cache )] = Utilities.deepCopy( value, cache )
    end

    return new
end

function Utilities.getSizeOfTable( tab ) -- Gets the actual size of a table. 
	local amount = 0
	for _, _ in pairs( tab ) do
		amount = amount + 1
	end
	return amount
end

function Utilities.getIndex( tab, func ) -- Returns a number and it's index given a function. 
	--[[
		Example:
		
		Number = { 1, 2, 3, 4, 10 }
		LargestNumber, Reference = GetIndex( Numbers, function ( Value1, Value2 ) return Value1 > Value2 end ) 
		print( LargestNumber, Reference ) --> 10, 5
	]]
    if #tab == 0 then return nil, nil end
    local key, value = 1, tab[1]
    for index = 2, #tab do
        if func( value, tab[index] ) then
            key, value = index, tab[index]
        end
    end
    return value, key
end

function Utilities.checkInput( ... ) -- Handles variable-input. 
	local input = {}
	if ... then 
		if type( ... ) ~= 'table' then input = { ... } else input = ... end 
	end
	return input
end

function Utilities.flattenArray( list ) -- Flattens an array so that all information is at one level (no nested tables). 
	if type( list ) ~= 'table' then return { list } end
	local flattenedList = {}
	for _, value in ipairs( list ) do
		for _, element in ipairs( Utilities.flattenArray( value ) ) do
			flattenedList[#flattenedList + 1] = element
		end
	end
	return flattenedList
end

function Utilities.flattenTable( list ) -- Works with all tables
	if type( list ) ~= 'table' then return { list } end
	local flattendTable = {}
	for _, value in pairs( list ) do
		for _, element in pairs( Utilities.flattenTable( value ) ) do
			flattendTable[#flattendTable + 1] = element
		end
	end
	return flattendTable
end

function Utilities.deepCompare( tab1, tab2, ignoreMeta ) -- Compares two tables and what's inside of those tables. 
	local type1 = type( tab1 )
	local type2 = type( tab2 )
	if type1 ~= type2 then return false end
	if type1 ~= 'table' and type2 ~= 'table' then return tab1 == tab2 end
	local mt = getmetatable( tab1 )
	if not ignoreMeta and mt and mt.__eq then return tab1 == tab2 end
	
	for index1, value1 in pairs( tab1 ) do
		local value2 = tab2[index1]
		if value2 == nil or not Utilities.deepCompare( value1, value2 ) then return false end
	end
	for index2, value2 in pairs( tab2 ) do
		local value1 = tab1[index2]
		if value1 == nil or not Utilities.deepCompare( value1, value2 ) then return false end
	end
	return true
end

function Utilities.loadBase64Image( file, name ) -- Loads an image given the base-64 encoded information. 
	return love.graphics.newImage( love.image.newImageData( love.filesystem.newFileData( file, name:gsub( '_', '.' ), 'base64' ) ) )
end

function Utilities.loadBase64Sound( file, name ) -- Loads a sound given the base-64 encoded information. 
	return love.audio.newSource( love.sound.newSoundData( love.filesystem.newFileData( file, name:gsub( '_', '.' ), 'base64' ) ), 'stream' )
end

function Utilities.clamp( minimum, maximum, value ) -- Makes sure a number is between the minimum and the maximum. 
	return math.max( minimum, math.min( maximum, value ) )
end

function Utilities.normalize( minimum, maximum, value ) -- normalize a value (put it on a scale from 0 to 1 )
	return ( value - minimum ) / ( maximum - minimum )
end

function Utilities.lerp( minimum, maximum, value ) -- Linear Interpolate a value (change from a scale from 0 to 1 to a range of values).
	return ( maximum - minimum ) * value + minimum
end

function Utilities.map( min1, max1, value, min2, max2 ) -- Maps from one scale to another.
	return ( value - min1 ) / ( max1 - min1 ) * ( max2 - min2 ) + min2
end

function Utilities.sign( number ) 
	return number > 0 and 1 or number < 0 and -1 or 0 
end

function Utilities.boundingBox( x, y, boxX, boxY, boxW, boxH )
	if x >= boxX and x <= boxX + boxW and y >= boxY and y <= boxY + boxH then
		return true
	end
	return false
end

function Utilities.cycle( index, increment, tab )
	index = index or 0
	increment = increment or 1
	
	local new = index + increment
	if new < 1 then new = #tab + new
	elseif new > #tab then new = new - #tab end
	return new
end

return Utilities