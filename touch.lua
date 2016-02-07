local MOAITouchSensor = _G.MOAITouchSensor
local MOAIRenderMgr = _G.MOAIRenderMgr
local MOAIInputMgr = _G.MOAIInputMgr

assert( MOAITouchSensor and MOAIInputMgr and MOAIInputMgr, 'MOAI not found' )

local TOUCH_UP = MOAITouchSensor.TOUCH_UP
local TOUCH_DOWN = MOAITouchSensor.TOUCH_DOWN
local TOUCH_MOVE = MOAITouchSensor.TOUCH_MOVE
local TOUCH_CANCEL = MOAITouchSensor.TOUCH_CANCEL
local getRenderTable = MOAIRenderMgr.getRenderTable

local LEFT = 1
local RIGHT = 2
local MIDDLE = 3

local Touch = {
	LEFT = LEFT,
	RIGHT = RIGHT, 
	MIDDLE = MIDDLE,

	x = 0,
	y = 0,
	taps = {},
	tapCount = 0,
	
	emit = function() end,
}
 
local function touchCallback( eventType, idx, x, y, tapCount )
	Touch.tapCount = tapCount
	Touch.x = x
	Touch.y = y

	if eventType == TOUCH_UP then
		Touch.taps[idx] = nil
		Touch:onTouchUp( idx, x, y )

	elseif eventType == TOUCH_DOWN then
		Touch.taps[idx] = {x0 = x, y0 = y, x = x, y = y, dx = 0, dy = 0}
		Touch:onTouchDown( idx, x, y )

	elseif eventType == TOUCH_MOVE then
		local tap = Touch.taps[idx]
		if not tap then
			Touch.taps[idx] = {x0 = x, y0 = y, x = x, y = y, dx = 0, dy = 0}
			Touch:onTouchDown( idx, x, y )
		else
			local dx, dy = x - tap.x, y - tap.y
			tap.dx, tap.dy = dx, dy
			tap.x, tap.y = x, y
			Touch:onTouchMove( idx, x, y, dx, dy )
		end  
	elseif eventType == TOUCH_CANCEL then
		Touch.taps = {}
		Touch.tapCount = 0
		Touch:onTouchCancel()
	end
end
	
local function pointerCallback( x, y )
	local dx, dy = x - Touch.x, y - Touch.y
	Touch.x = x
	Touch.y = y
	for idx, tap in pairs( Touch.taps ) do
		tap.x, tap.y, tap.dx, tap.dy = x, y, dx, dy
		Touch:onTouchMove( idx, x, y, dx, dy ) 
	end
	Touch:onTouchMove( 0, x, y, dx, dy ) 
end

local function updateTapCount() 
	Touch.tapCount = 0
	if Touch.taps[LEFT] then Touch.tapCount = Touch.tapCount + 1 end
	if Touch.taps[RIGHT] then Touch.tapCount = Touch.tapCount + 1 end
	if Touch.taps[MIDDLE] then Touch.tapCount = Touch.tapCount + 1 end
end

local function onMouse( button, down )
	if down then
		Touch.taps[button] = { x = Touch.x, y = Touch.y }
		updateTapCount()
		Touch:onTouchDown( button, Touch.x, Touch.y )
	else
		Touch.taps[button] = nil
		updateTapCount()
		Touch:onTouchUp( button, Touch.x, Touch.y )
	end
end

local function mouseLeftCallback( down )
	onMouse( LEFT, down )
end

local function mouseRightCallback( down )
	onMouse( RIGHT, down )
end

local function mouseMiddleCallback( down )
	onMouse( MIDDLE, down )
end


function Touch.processTouchEvent( self, x, y, event, ... )
	self:emit( event, x, y, ... )
	local layers = getRenderTable()
	for i = #layers, 1, -1 do
		local layer = layers[i]
		if not layer.passive then
			local x_, y_ = layer:wndToWorld( x, y )
			local props = {layer:getPartition():propListForPoint( x_, y_ )}
			for j = #props, 1, -1 do
				local prop = props[j]
				local handler = prop[event]
				if handler then
					if handler( prop, self, x_, y_, ... ) then
						return
					end
				end
			end
		end
	end
end
	
function Touch.onTouchUp( self, idx, x, y ) 
	self:processTouchEvent( x, y, 'onTouchUp', idx ) 
end
	
function Touch.onTouchDown( self, idx, x, y ) 
	self:processTouchEvent( x, y, 'onTouchDown', idx ) 
end
	
function Touch.onTouchMove( self, idx, x, y, dx, dy ) 
	self:processTouchEvent( x, y, 'onTouchMove', idx, dx, dy ) 
end

function Touch.install()
	if MOAIInputMgr.device.touch then 
		MOAIInputMgr.device.touch:setCallback( touchCallback ) 
	end

	if MOAIInputMgr.device.pointer then
		MOAIInputMgr.device.pointer:setCallback( pointerCallback )
	end

	if MOAIInputMgr.device.mouseLeft then
		MOAIInputMgr.device.mouseLeft:setCallback( mouseLeftCallback )
	end

	if MOAIInputMgr.device.mouseRight then
		MOAIInputMgr.device.mouseRight:setCallback( mouseRightCallback )
	end

	if MOAIInputMgr.device.mouseMiddle then
		MOAIInputMgr.device.mouseMiddle:setCallback( mouseMiddleCallback )
	end
end

return Touch
