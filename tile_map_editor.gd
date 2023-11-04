extends TileMap

var current_draw_layer:int = 0
@export var default_terrain_layer:int = 0

var draw_elements:Array[LevelElement]
@export var current_element:LevelElement
@export var save_dialog:FileDialog

@export var terrain_layers_names:Array[StringName]

var current_draw_element:int = 0

var current_terrain_layer := default_terrain_layer

signal current_draw_element_changed(name:StringName)

#	new_tile_set_id:int = 0,
#	tile_is_terrain:bool = false,
#	new_atlas_coords:Vector2i = Vector2i(0,0),
#	new_terrain_layer:int = 0,
#	new_terrain_set:int = 0

func prepare_draw_elements():
	draw_elements.clear()
	print("N Terrain sets : %d" % tile_set.get_terrain_sets_count())
	for terrain_set_id in range(tile_set.get_terrain_sets_count()):
		var n_layers:int = tile_set.get_terrains_count(terrain_set_id)
		print("N Layers in Terrain %d : %d" % [terrain_set_id, n_layers])
		for terrain_layer_id in range(n_layers):
			draw_elements.append(LevelElement.new(
				0,
				true,
				Vector2i.ZERO,
				terrain_layer_id,
				terrain_set_id,
				tile_set.get_terrain_name(terrain_set_id, terrain_layer_id)
			))
			print(len(draw_elements))


func choose_element(new_element:int):
	if new_element >= len(draw_elements):
		new_element = 0
	if new_element < 0:
		new_element = len(draw_elements) - 1
	current_draw_element = new_element
	current_element = draw_elements[current_draw_element]
	current_draw_element_changed.emit(current_element.name)

func _ready():
	prepare_draw_elements()
	choose_element(0)

func _input(event):
	if event is InputEventMouse:
		var mouse_click_event := event as InputEventMouse
		var mouse_position = get_global_mouse_position()
		var click_position := local_to_map(to_local(mouse_position))
		if (mouse_click_event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
			var click_coordinates:Array[Vector2i] = [click_position]
			current_element.draw_tile(self, current_draw_layer, click_position)
			#set_cells_terrain_connect(0, click_coordinates, 0, 0, false)
		if (mouse_click_event.button_mask & MOUSE_BUTTON_MASK_RIGHT) != 0:
			set_cell(0, click_position, )
	elif event is InputEventKey:
		var keyboard_event := event as InputEventKey
		if keyboard_event.pressed:
			return

		match keyboard_event.keycode:
			KEY_S:
				print(save_data())
				#save_dialog.show()
			KEY_UP:
				choose_element(current_draw_element+1)
			KEY_DOWN:
				choose_element(current_draw_element-1)
			_:
				return


func vec2i_to_array(vec2i:Vector2i) -> PackedInt32Array:
	return PackedInt32Array([vec2i[0], vec2i[1]])

func vec2i_to_int(vec2i:Vector2i) -> int:
	var x:int = (vec2i[0] & 0xffff) << 0
	var y:int = (vec2i[1] & 0xffff) << 16
	return (x | y)

var checked_bits := PackedInt64Array([
	TileSet.CELL_NEIGHBOR_TOP_SIDE,
	TileSet.CELL_NEIGHBOR_LEFT_SIDE,
	TileSet.CELL_NEIGHBOR_BOTTOM_SIDE,
	TileSet.CELL_NEIGHBOR_RIGHT_SIDE
])

var checked_bits_to_string := PackedStringArray([
	"TOP", "RIGHT", "BOTTOM", "LEFT"
])

var directions : Array[TileSet.CellNeighbor] = [
	TileSet.CELL_NEIGHBOR_RIGHT_SIDE,
	TileSet.CELL_NEIGHBOR_RIGHT_CORNER,
	TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE,
	TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER,
	TileSet.CELL_NEIGHBOR_BOTTOM_SIDE,
	TileSet.CELL_NEIGHBOR_BOTTOM_CORNER,
	TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE,
	TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER,
	TileSet.CELL_NEIGHBOR_LEFT_SIDE,
	TileSet.CELL_NEIGHBOR_LEFT_CORNER,
	TileSet.CELL_NEIGHBOR_TOP_LEFT_SIDE,
	TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER,
	TileSet.CELL_NEIGHBOR_TOP_SIDE,
	TileSet.CELL_NEIGHBOR_TOP_CORNER,
	TileSet.CELL_NEIGHBOR_TOP_RIGHT_SIDE,
	TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER
]

func _get_tile_peering_bits(tile_data:TileData) -> int:
	var value:int = 0
	for direction_bit in range(len(checked_bits)):
		var direction := checked_bits[direction_bit]
		#var direction:int = checked_bits[neighbor]
		var peering_bit := tile_data.get_terrain_peering_bit(direction)
		if peering_bit != -1:
			value |= 1 << direction_bit
	return value

func _direction_bits_to_string(bits:int) -> PackedStringArray:
	var used_bits := (bits & 0xf)
	var directions := PackedStringArray()
	for bit in range(4):
		if ((1 << bit) & used_bits) != 0:
			directions.append(checked_bits_to_string[bit])
	return directions

func save_to_file(filepath:String):
	var file_access := FileAccess.open(filepath, FileAccess.WRITE)
	if file_access == null:
		return
	file_access.store_string(save_data())
	file_access.close()

func save_data() -> String:

	var inventory_database = {}
	var world = {}
	
	var n_draw_elements:int = len(draw_elements)

	var used_cells:Array[Vector2i] = get_used_cells(current_terrain_layer)
	var n_used_cells = len(used_cells)

	for terrain_set_id in range(tile_set.get_terrain_sets_count()):
		var layer_name := terrain_layers_names[terrain_set_id]
		var layer_data:Array[Array] = []
		var n_terrains := tile_set.get_terrains_count(terrain_set_id)
		layer_data.resize(n_terrains)
		for terrain_id in range(n_terrains):
			layer_data[terrain_id] = []
		world[layer_name] = layer_data

	for cell in range(n_used_cells):
		var tile_coords:Vector2i = used_cells[cell]
		var tile := get_cell_tile_data(current_draw_layer, tile_coords)

		var layer_name:StringName = terrain_layers_names[tile.terrain_set]
		var coords_array := vec2i_to_array(tile_coords)
		coords_array.append(_get_tile_peering_bits(tile))
		world[layer_name][tile.terrain].append(coords_array)

	var out_dictionary:Dictionary = {
		"version": 1,
		"world": world
	}

	return JSON.stringify(out_dictionary)
