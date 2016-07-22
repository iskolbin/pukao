local type, unpack = type, table.unpack or unpack

local Moai = {}

local function translateMOAI( class ) 
	local common, derived = {}, {}
	
	local function translateReserve( name_, reserve )
		local name = name_:match( 'reserve(%w+)s')
		local newName = name:sub( 1, 1 ):lower() .. name:sub( 2 ) .. 's'
		local setter = class.getInterfaceTable()['set' .. name]
		if setter then
			derived[newName] = function( self, args )
				reserve( #args )
				for i = 1, #args do
					if type( args[i] ) == 'table' then
						setter( self, i, unpack( args[i] ))
					else
						setter( self, args[i] )
					end
				end
			end
		else
			derived[newName] = reserve
		end
	end

	local function translateInsert( name_, insert )
		local name = name_:match( 'insert(%w+)' )
		local newName = name:sub( 1, 1 ):lower() .. name:sub( 2 ) .. 's'
		derived[newName] = function( self, args )
			for i = 1, #args do
				if type( args[i] ) == 'table' then
					insert( self, i, unpack( args[i] ))
				else
					insert( self, args[i] )
				end
			end
		end
	end

	local out = {}
	
	for name, method in pairs( class.getInterfaceTable() ) do
		if name:sub( 1, 3 ) == 'set' then
			common[name:sub( 4, 4 ):lower() .. name:sub( 5 )] = method
		elseif name:sub( 1, 4 ) == 'init' then
			common[name:sub( 5, 5 ):lower() .. name:sub( 6 )] = method
		elseif name:match( 'reserve(%w+)s' ) then
			translateReserve( name, method )
		elseif name:match( 'insert(%w+)' ) then
			translateInsert( name, method )
		  --else
			--print( 'Method not translated:', name )
		end
	end

	for name, const in pairs( class ) do
		if name:upper() == name then
			out[name] = const
		end
	end

	local function new( _, kwargs, private )
		local self = class.new()
		if kwargs then
			for name, args in pairs( kwargs ) do
				if name == '_' then
					for k, v in pairs( args ) do
						self[k] = v
					end
				else
					local method = common[name]
					if method then
						if type( args ) == 'table' then
							method( self, unpack( args ))
						else
							method( self, args )
						end
					else
						local method_ = derived[name]
						if method_ then
							method_( self, args )
						else
							print( 'Unregistred method:' .. name )
						end
					end
				end
			end
		end

		if private then
			for k, v in pairs( private ) do
				self[k] = v
			end
		end

		return self
	end

	return setmetatable( out, {__call = new} )
end

for name, class in pairs( _G ) do
	if type( name ) == 'string' and name:sub( 1, 4 ) == 'MOAI' then
		if class.getInterfaceTable then
			Moai[name:sub( 5 )] = translateMOAI( class )
		else
			Moai[name:sub( 5 )] = class
		end
	end
end

return Moai
