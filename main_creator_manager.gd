extends Node2D

@export var tilemap:TileMap
@export var camera:Camera2D

@export var size_in_blocks:Vector2i

# Called when the node enters the scene tree for the first time.
func _ready():
	if tilemap == null:
		printerr("Tilemap not set !")
		set_process(false)
		return
	if camera == null:
		printerr("Camera not set !")
		set_process(false)
		return
	var limits := tilemap.tile_set.tile_size * size_in_blocks
	camera.limit_right = limits.x
	camera.limit_top   = -limits.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
