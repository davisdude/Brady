local Square = {}

function Square.new( x, y, w, h )
	local self = { 
		x = x, y = y, w = w, h = h,
		color = { 255, 255, 255 },
		mode = 'fill',
		draw = function( self )
			love.graphics.rectangle( self.mode, self.x, self.y, self.w, self.h )
		end
	}
	return self
end

return setmetatable( Square, { __call = function( _, ... ) return Square.new( ... ) end } )
