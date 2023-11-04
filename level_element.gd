extends Resource

class_name LevelElement

@export var name:StringName
@export var tileset_id:int = 0
@export var is_a_terrain:bool = false : set = _set_terrain

@export var atlas_coords:Vector2i = Vector2i(0,0)

@export var terrain_layer:int = 0
@export var terrain_set:int = 0

var draw_function:Callable = _draw_terrain_tile

func _set_terrain(new_terrain_state:bool):
	is_a_terrain = new_terrain_state
	draw_function = _draw_terrain_tile if is_a_terrain else _draw_simple_tile

func _draw_terrain_tile(tilemap:TileMap, tilemap_layer:int, tile_position:Vector2i):
	tilemap.set_cells_terrain_connect(tilemap_layer, [tile_position], terrain_set, terrain_layer)

func _draw_simple_tile(tilemap:TileMap, tilemap_layer:int, tile_position:Vector2i):
	tilemap.set_cell(tilemap_layer, tile_position, tileset_id, atlas_coords)

func draw_tile(tilemap:TileMap, tilemap_layer:int, tile_position:Vector2i):
	draw_function.call(tilemap, tilemap_layer, tile_position)

func set_draw_function():
	draw_function = _draw_terrain_tile if is_a_terrain else _draw_simple_tile

func _init(
	new_tile_set_id:int = 0,
	tile_is_terrain:bool = false,
	new_atlas_coords:Vector2i = Vector2i(0,0),
	new_terrain_layer:int = 0,
	new_terrain_set:int = 0,
	new_name:StringName = &""
):
	tileset_id = new_tile_set_id
	is_a_terrain = tile_is_terrain
	atlas_coords = new_atlas_coords
	terrain_layer = new_terrain_layer
	terrain_set = new_terrain_set
	draw_function = _draw_terrain_tile if tile_is_terrain else _draw_simple_tile
	name = new_name

func set_terrain(tile_is_terrain:bool, new_terrain_layer:int = 0, new_terrain_set:int = 0):
	if tile_is_terrain:
		is_a_terrain = true
		terrain_layer = new_terrain_layer
		terrain_set = new_terrain_set
	
