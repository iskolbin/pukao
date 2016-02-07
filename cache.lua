local newTexture = _G.MOAITexture.new
local newQuad = _G.MOAIGfxQuad2D.new
local newFont = _G.MOAIFont.new

assert( newTexture and newQuad and newFont, 'MOAI not found' )

local cache = { 
	textures = setmetatable({},{__mode = 'kv'}),
	quads = setmetatable({},{__mode = 'kv'}),
	fonts = setmetatable({},{__mode = 'kv'}),
}

function cache.Texture( k )
	local texture = cache.textures[k] 
	if not texture then
		texture = newTexture()
		texture:load( k ) 
		cache.textures[k] = texture
	end
	return texture
end

function cache.Quad( k )
	local quad = cache.quads[k] 
	if not quad then
		local texture = cache.Texture( k )
		local w, h = texture:getSize()
		quad = newQuad()
		quad:setTexture( texture )
		quad:setRect( -0.5*w, -0.5*h, 0.5*w, 0.5*h )
		cache.quads[k] = quad
	end
	return quad
end

local UPPER = 'QWERTYUIOPASDFGHJKLZXCVBNM'
local LOWER = 'qwertyuiopasdfghjklzxcvbnm'
local DIGITS = '01234567890'
local PUNCTUATION = '.,;:\'"`?!'
local SPECIAL = '~@#$%^&*/|\\<>+-()[]{}№'

function cache.Font( path, size, charcodes, dpi_ )
	local dpi = dpi_ or 120
	local k = ('%s_%d_%d_%s'):format( path, size, dpi, charcodes ) 
	local font = cache.fonts[k]
	if not font then
		if charcodes:sub(1,2) == '::' then
			local charcodes_ = ' \n\t'
			for i = 3, #charcodes do
				local c = charcodes:sub(i,i)
				if     c == 'u' then charcodes_ = charcodes_ .. UPPER
				elseif c == 'l' then charcodes_ = charcodes_ .. LOWER
				elseif c == 'a' then charcodes_ = charcodes_ .. UPPER .. LOWER
				elseif c == 'd' then charcodes_ = charcodes_ .. DIGITS
				elseif c == 'w' then charcodes_ = charcodes_ .. UPPER .. LOWER .. DIGITS
				elseif c == 'p' then charcodes_ = charcodes_ .. PUNCTUATION
				elseif c == 's' then charcodes_ = charcodes_ .. SPECIAL
				end
			end
			charcodes = charcodes_
		end

		font = newFont()
		font:load( path )
		font:setDefaultSize( size, dpi )
		font:preloadGlyphs( charcodes, size, dpi )
		cache.fonts[k] = font	
	end
	return font
end

return cache
