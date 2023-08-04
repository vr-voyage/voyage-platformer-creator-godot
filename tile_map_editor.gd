extends TileMap

@export var terrain_layer:int = 0

func _input(event):
	if event is InputEventMouse:
		var mouse_click_event := event as InputEventMouse
		var mouse_position = get_global_mouse_position()
		var click_position := local_to_map(to_local(mouse_position))
		if (mouse_click_event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
			var click_coordinates:Array[Vector2i] = [click_position]
			print(click_coordinates)
			set_cells_terrain_connect(0, click_coordinates, 0, 0, false)
			print("a")
		if (mouse_click_event.button_mask & MOUSE_BUTTON_MASK_RIGHT) != 0:
			set_cell(0, click_position, )
	elif event is InputEventKey:
		var keyboard_event := event as InputEventKey
		if keyboard_event.keycode == KEY_S and keyboard_event.pressed:
			save_data()

func vec2i_to_array(vec2i:Vector2i) -> PackedInt32Array:
	return PackedInt32Array([vec2i[0], vec2i[1]])

func vec2i_to_int(vec2i:Vector2i) -> int:
	var x:int = (vec2i[0] & 0xffff) << 0
	var y:int = (vec2i[1] & 0xffff) << 16
	return (x | y)

func save_data():
	var output_data = []
	var used_cells:Array[Vector2i] = get_used_cells(terrain_layer)
	var n_used_cells = len(used_cells)
	output_data.resize(n_used_cells)
	var dictionary:Dictionary = {}
	for cell in range(n_used_cells):
		var tile_coords:Vector2i = used_cells[cell]
		var tile_id:Vector2i = get_cell_atlas_coords(0, tile_coords)
		if not dictionary.has(tile_id):
			dictionary[tile_id] = []
		dictionary[tile_id].append(tile_coords)
		output_data[cell] = [vec2i_to_array(tile_id),vec2i_to_array(tile_coords)]
	print(JSON.stringify(output_data))

