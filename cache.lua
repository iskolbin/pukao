local newTexture = MOAITexture.new
local newQuad = MOAIGfxQuad2D.new
local newFont = MOAIFont.new

local cache = { 
	textures = setmetatable({},{__mode = 'kv'}),
	quads = setmetatable({},{__mode = 'kv'}),
	fonts = setmetatable({},{__mode = 'kv'}),
}

cache.Texture = function( k )
	local texture = cache.textures[k] 
	if not texture then
		texture = newTexture()
		texture:load( k ) 
		cache.textures[k] = texture
	end
	return texture
end

cache.Quad = function( k )
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

cache.Font = function( path, size, charcodes, dpi )
	local dpi = dpi or 120
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
