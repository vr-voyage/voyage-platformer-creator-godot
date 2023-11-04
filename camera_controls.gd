extends Camera2D

@export var min_zoom:float = 1.364
@export var max_zoom:float = 4



func clamp_zoom() -> void:
	zoom.x = clampf(zoom.x, min_zoom, max_zoom)
	zoom.y = clampf(zoom.y, min_zoom, max_zoom)

func clamp_position() -> void:
	position.x = clampf(position.x, limit_left, limit_right)
	position.y = clampf(position.y, limit_top, limit_bottom)

func _input(event):
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		var button_mask := mouse_event.button_mask
		if button_mask & (1 << (MOUSE_BUTTON_WHEEL_DOWN - 1)):
			printerr("Zoom down")
			zoom = zoom * 0.9
			clamp_zoom()
		elif button_mask & (1 << (MOUSE_BUTTON_WHEEL_UP - 1)):
			printerr("Zoom up")
			zoom = zoom * 1.1
			clamp_zoom()

	if event is InputEventMouseMotion:
		var mouse_event := event as InputEventMouseMotion
		var button_mask := mouse_event.button_mask
		if button_mask & (1 << (MOUSE_BUTTON_MIDDLE - 1)):
			position -= event.relative / zoom
			clamp_position()
