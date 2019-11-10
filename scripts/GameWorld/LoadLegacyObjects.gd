extends Node

# Geometric Objects
const Wall = preload("res://scripts/GameWorld/LegacyWall.gd")
const Plat = preload("res://scripts/GameWorld/LegacyPlatform.gd")
const Pillar = preload("res://scripts/GameWorld/Pillar.gd")
const Ramp = preload("res://scripts/GameWorld/LegacyRamp.gd")

func create_wall(disp : Vector2, start : Vector2, texColour, height : int, level: int):
	start = start / 5.0
	disp = disp / 5.0
	var end : Vector2 = start + disp
	
	var new_wall = Wall.new(start, level)
	new_wall.end = end
	if typeof(texColour) == TYPE_INT:
		new_wall.texture = WorldTextures.getWallTexture(texColour)
	else:
		new_wall.texture = WorldTextures.TextureID.COLOR
		new_wall.colour = texColour
	new_wall.change_height_value(height)
	
	get_parent().call("add_geometric_object", new_wall, level)

func create_triwall(pos : Vector2, is_bottom : int, texColour, direction : int, level: int):
	pos = pos / 5.0
	
	var new_triwall = Wall.new(pos, level)
	var disp
	match (direction):
		1: disp = Vector2(0, 4)
		2: disp = Vector2(0, -4)
		3: disp = Vector2(4, 0)
		4: disp = Vector2(-4, 0)
		5: disp = Vector2(3, 3)
		6: disp = Vector2(3, -3)
		7: disp = Vector2(-3, -3)
		8: disp = Vector2(-3, 3)
	if is_bottom == 1:
		new_triwall.wallShape = WorldConstants.WallShape.HALFWALLBOTTOM
		new_triwall.end = pos + disp
	else:
		new_triwall.wallShape = WorldConstants.WallShape.HALFWALLTOP
		new_triwall.end = pos
		new_triwall.start = pos + disp

	if typeof(texColour) == TYPE_INT:
		new_triwall.texture = WorldTextures.getWallTexture(texColour)
	else:
		new_triwall.texture = WorldTextures.TextureID.COLOR
		new_triwall.colour = texColour
	
	get_parent().call("add_geometric_object", new_triwall, level)

func create_plat(pos : Vector2, size : int, texColour, height : int, shape, level: int):
	pos = pos / 5.0
	
	var new_plat = Plat.new(pos, level)
	new_plat.size = size
	new_plat.platShape = shape
	if typeof(texColour) == TYPE_INT:
		new_plat.texture = WorldTextures.getPlatTexture(texColour)
	else:
		new_plat.texture = WorldTextures.TextureID.COLOR
		new_plat.colour = texColour
	new_plat.change_height_value(height)
	
	get_parent().call("add_geometric_object", new_plat, level)

func create_pillar(pos : Vector2, isDiagonal : int, size : int, texColour, height : int, level: int):
	pos = pos / 5.0
	
	var new_pillar = Pillar.new(pos, level)
	new_pillar.size = size
	if typeof(texColour) == TYPE_INT:
		new_pillar.texture = WorldTextures.getWallTexture(texColour)
	else:
		new_pillar.texture = WorldTextures.TextureID.COLOR
		new_pillar.colour = texColour
	new_pillar.change_height_value(height)
	new_pillar.diagonal = bool(isDiagonal - 1)
	
	get_parent().call("add_geometric_object", new_pillar, level)

func create_ramp(end : Vector2, direction : int, texColour, level: int):
	end = end / 5.0
	var start
	match direction:
		1: start = end + Vector2(0,  4)
		2: start = end + Vector2(0, -4)
		3: start = end + Vector2(4,  0)
		4: start = end + Vector2(-4, 0)
		5: start = end + Vector2(3,  3)
		6: start = end + Vector2(3, -3)
		7: start = end + Vector2(-3,-3)
		8: start = end + Vector2(-3, 3)
		_: return
	
	var new_ramp = Ramp.new(start, level)
	new_ramp.end = end
	if typeof(texColour) == TYPE_INT:
		new_ramp.texture = WorldTextures.getPlatTexture(texColour)
	else:
		new_ramp.texture = WorldTextures.TextureID.COLOR
		new_ramp.colour = texColour
		
	get_parent().call("add_geometric_object", new_ramp, level)

func create_spawn(pos : Vector2, direction : int, level : int):
	var new_spawn = preload("res://Entities/Legacy/Spawn/Spawn.tscn").instance()
	
	pos = pos / 5.0
	new_spawn.set_translation(Vector3(pos.x, level * WorldConstants.LEVEL_HEIGHT, pos.y))
	
	get_parent().call("add_entity", new_spawn)