local newTexture = _G.MOAITexture.new
local newQuad = _G.MOAIGfxQuad2D.new
local newFont = _G.MOAIFont.new

assert( newTexture and newQuad and newFont, 'MOAI not found' )

local cache = { 
	_textures = setmetatable({},{__mode = 'kv'}),
	_quads = setmetatable({},{__mode = 'kv'}),
	_fonts = setmetatable({},{__mode = 'kv'}),
}

function cache.Texture( k )
	local texture = cache._textures[k] 
	if not texture then
		texture = newTexture()
		texture:load( k ) 
		cache._textures[k] = texture
	end
	return texture
end

function cache.Quad( k )
	local quad = cache._quads[k] 
	if not quad then
		local texture = cache.Texture( k )
		local w, h = texture:getSize()
		quad = newQuad()
		quad:setTexture( texture )
		quad:setRect( -0.5*w, -0.5*h, 0.5*w, 0.5*h )
		cache._quads[k] = quad
	end
	return quad
end

local UPPER = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
local LOWER = 'abcdefghijklmnopqrstuvwxyz'
local DIGITS = '01234567890'
local PUNCTUATION = '.,;:\'"`?!'
local SPECIAL = '~@#$%^&*/|\\<>+-()[]{}№'
local LO_CYR = 'абвгдеёжзийклмнопрстуфхцшщъыьэюя'
local UP_CYR = 'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦШЩЪЫЬЭЮЯ'

function cache.Font( path, size, charcodes, dpi_ )
	local dpi = dpi_ or 120
	local k = ('%s_%d_%d_%s'):format( path, size, dpi, charcodes ) 
	local font = cache._fonts[k]
	if not font then
		if charcodes:sub(1,2) == '::' then
			local charcodes_ = ' \r\n\t'
			local upper, lower, cyrillic = false, false
			for i = 3, #charcodes do
				local c = charcodes:sub(i,i)
				if     c == 'u' then upper = true; charcodes_ = charcodes_ .. UPPER
				elseif c == 'l' then lower = true; charcodes_ = charcodes_ .. LOWER
				elseif c == 'c' then cyrillic = true;
				elseif c == 'd' then charcodes_ = charcodes_ .. DIGITS
				elseif c == 'p' then charcodes_ = charcodes_ .. PUNCTUATION
				elseif c == 's' then charcodes_ = charcodes_ .. SPECIAL
				end

				if cyrillic then
					if lower then charcodes_ = charcodes_ .. LO_CYR end
					if upper then charcodes_ = charcodes_ .. UP_CYR end
				end
			end
			charcodes = charcodes_
		end

		font = newFont()
		font:load( path )
		font:setDefaultSize( size, dpi )
		font:preloadGlyphs( charcodes, size, dpi )
		cache._fonts[k] = font	
	end
	return font
end

return cache
