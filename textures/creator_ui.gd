extends Control

@export var current_item_name_label:Label

func show_current_element_name(element_name:StringName):
	current_item_name_label.text = element_name
