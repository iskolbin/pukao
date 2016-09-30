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

local touch = {
	LEFT = LEFT,
	RIGHT = RIGHT, 
	MIDDLE = MIDDLE,

	TOUCH_UP = TOUCH_UP,
	TOUCH_DOWN = TOUCH_DOWN,
	TOUCH_MOVE = TOUCH_MOVE,
	TOUCH_CANCEL = TOUCH_CANCEL,

	x = 0,
	y = 0,
	taps = {},
	tapCount = 0,
	
	emit = function() end,
}
 
local function touchCallback( eventType, idx, x, y, tapCount )
	touch.tapCount = tapCount
	touch.x = x
	touch.y = y

	if eventType == TOUCH_UP then
		touch.taps[idx] = nil
		touch.ontouchup( idx, x, y )

	elseif eventType == TOUCH_DOWN then
		touch.taps[idx] = {x0 = x, y0 = y, x = x, y = y, dx = 0, dy = 0}
		touch.ontouchdown( idx, x, y )

	elseif eventType == TOUCH_MOVE then
		local tap = touch.taps[idx]
		if not tap then
			touch.taps[idx] = {x0 = x, y0 = y, x = x, y = y, dx = 0, dy = 0}
			touch.ontouchdown( idx, x, y )
		else
			local dx, dy = x - tap.x, y - tap.y
			tap.dx, tap.dy = dx, dy
			tap.x, tap.y = x, y
			touch.ontouchmove( idx, x, y, dx, dy )
		end  
	elseif eventType == TOUCH_CANCEL then
		touch.taps = {}
		touch.tapCount = 0
		touch.ontouchcancel( idx, x, y )
	end
end
	
local function pointerCallback( x, y )
	local dx, dy = x - touch.x, y - touch.y
	touch.x = x
	touch.y = y
	for idx, tap in pairs( touch.taps ) do
		tap.x, tap.y, tap.dx, tap.dy = x, y, dx, dy
		touch.ontouchmove( idx, x, y, dx, dy ) 
	end
	touch.ontouchmove( 0, x, y, dx, dy ) 
end

local function updateTapCount() 
	touch.tapCount = 0
	if touch.taps[LEFT] then touch.tapCount = touch.tapCount + 1 end
	if touch.taps[RIGHT] then touch.tapCount = touch.tapCount + 1 end
	if touch.taps[MIDDLE] then touch.tapCount = touch.tapCount + 1 end
end

local function onMouse( button, down )
	if down then
		touch.taps[button] = { x = touch.x, y = touch.y }
		updateTapCount()
		touch.ontouchdown( button, touch.x, touch.y )
	else
		touch.taps[button] = nil
		updateTapCount()
		touch.ontouchup( button, touch.x, touch.y )
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


function touch.process( event, x, y, ... )
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
					if handler( prop, touch, x_, y_, ... ) then
						return
					end
				end
			end
		end
	end
end
	
function touch.ontouchup( idx, x, y ) 
	touch.process( 'onTouchUp', x, y, idx ) 
end
	
function touch.ontouchdown( idx, x, y ) 
	touch.process( 'onTouchDown', x, y, idx ) 
end
	
function touch.ontouchmove( idx, x, y, dx, dy ) 
	touch.process( 'onTouchMove', x, y, idx, dx, dy ) 
end

function touch.ontouchcancel( idx, x, y )
	touch.process( 'onTouchCancel', x, y, idx )
end

function touch.install(...)
	local all = false
	local args = {...}
	if #args == 0 then
		all = true
	else
		for _, v in pairs( install ) do
			args[v] = true
		end
	end

	if all or args.touch or MOAIInputMgr.device.touch then 
		MOAIInputMgr.device.touch:setCallback( touchCallback ) 
	end

	if all or args.pointer or MOAIInputMgr.device.pointer then
		MOAIInputMgr.device.pointer:setCallback( pointerCallback )
	end

	if all or args.mouseLeft or MOAIInputMgr.device.mouseLeft then
		MOAIInputMgr.device.mouseLeft:setCallback( mouseLeftCallback )
	end

	if all or args.mouseRight or MOAIInputMgr.device.mouseRight then
		MOAIInputMgr.device.mouseRight:setCallback( mouseRightCallback )
	end

	if all or args.mouseMiddle or MOAIInputMgr.device.mouseMiddle then
		MOAIInputMgr.device.mouseMiddle:setCallback( mouseMiddleCallback )
	end
end

return touch
