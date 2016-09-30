local MOAIScriptDeck = _G.MOAIScriptDeck
local MOAIGfxDevice = _G.MOAIGfxDevice
local MOAIDraw = _G.MOAIDraw

assert( MOAIScriptDeck and MOAIGfxDevice and MOAIDraw, 'MOAI not found' )

local newScriptDeck = MOAIScriptDeck.new
local setPenColor, setPenWidth, setPointSize = MOAIGfxDevice.setPenColor, MOAIGfxDevice.setPenWidth, MOAIGfxDevice.setPointSize
local fillRect, fillFan, fillCircle, fillEllipse = MOAIDraw.fillRect, MOAIDraw.fillFan, MOAIDraw.fillCircle, MOAIDraw.fillEllipse
local drawRect, drawLine, drawCircle, drawEllipse, drawPoints = MOAIDraw.drawRect, MOAIDraw.drawLine, MOAIDraw.drawCircle, MOAIDraw.drawEllipse, MOAIDraw.drawPoints

local shape = {}

function shape.Rect( kwargs )
	local width, height = kwargs.width or kwargs[1], kwargs.height or kwargs[2]
	local fill, line = kwargs.fill, kwargs.line
	local hw, hh = 0.5 * width, 0.5 * height
	local deck = newScriptDeck()
	deck:setRect( -hw, -hh, hw, hh )
	deck:setDrawCallback( function()
		if fill then
			setPenColor( fill[1], fill[2], fill[3], fill[4] or 1.0 )
			fillRect( -hw, -hh, hw, hh )
		end

		if line then
			setPenWidth( line.width )
			setPenColor( line[1], line[2], line[3], line[4] or 1.0 )
			drawRect( -hw, -hh, hw, hh )
		end
	end )
	return deck
end

function shape.Circle( kwargs )
	local radius = kwargs.radius or kwargs[1]
	local fill, line, steps = kwargs.fill, kwargs.line, kwargs.steps
	local deck = newScriptDeck()
	deck:setRect( -radius, -radius, radius, radius )
	deck:setDrawCallback( function()
		if fill then
			setPenColor( fill[1], fill[2], fill[3], fill[4] or 1.0 )
			fillCircle( 0, 0, radius, steps or 32 )
		end

		if line then
			setPenWidth( line.width )
			setPenColor( line[1], line[2], line[3], line[4] or 1.0 )
			drawCircle( 0, 0, radius, steps or 32 )
		end
	end )
	return deck
end

function shape.Ellipse( kwargs )
	local radiusX = kwargs.radiusX or kwargs[1]
	local radiusY = kwargs.radiusY or kwargs[2]
	local fill, line, steps = kwargs.fill, kwargs.line, kwargs.steps
	local deck = newScriptDeck()
	deck:setRect( -radiusX, -radiusY, radiusX, radiusY )
	deck:setDrawCallback( function()

		if fill then
			setPenColor( fill[1], fill[2], fill[3], fill[4] or 1.0 )
			fillEllipse( 0, 0, radiusX, radiusY, steps or 32 )
		end

		if line then
			setPenWidth( line.width or 1 )
			setPenColor( line[1], line[2], line[3], line[4] or 1.0 )
			drawEllipse( 0, 0, radiusX, radiusY, steps or 32 )
		end
	end )
	return deck
end

function shape.Polygon( kwargs )
	local vertices = kwargs.vertices or kwargs
	local fill, line, point = kwargs.fill, kwargs.line, kwargs.point
	local minx, miny, maxx, maxy = math.huge, math.huge, -math.huge, -math.huge

	for i = 1, #vertices, 2 do
		if vertices[i] < minx then minx = vertices[i] end
		if vertices[i+1] < miny then miny = vertices[i+1] end
		if vertices[i] > maxx then maxx = vertices[i] end
		if vertices[i+1] > maxy then maxy = vertices[i+1] end
	end

	local deck = newScriptDeck()
	deck:setRect( minx, miny, maxx, maxy )
	deck:setDrawCallback( function()
		if fill then
			setPenColor( fill[1], fill[2], fill[3], fill[4] or 1.0 )
			fillFan( vertices )
		end

		if line then
			setPenWidth( line.width or 1 )
			setPenColor( line[1], line[2], line[3], line[4] or 1.0 )
			drawLine( vertices )
		end

		if point then
			setPointSize( point.size or 1 )
			setPenColor( point[1], point[2], point[3], point[4] or 1.0 )
			drawPoints( vertices )
		end
	end )
	return deck
end

return shape
