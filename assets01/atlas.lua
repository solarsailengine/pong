function loadatlas()
	local atlas = atlas()
	atlas.atlasPath = "atlas.png"
	atlas.atlasHeight = 64
	atlas.atlasWidth = 128

	local sprite
	
	-- White square sprite for paddles and ball
	sprite = addsprite()
	sprite.name = "white_square"
	sprite.frame.x = 0
	sprite.frame.y = 0
	sprite.frame.width = 32
	sprite.frame.height = 32

	return atlas
end

return loadatlas