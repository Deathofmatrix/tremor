extends Control

@onready var more_damage: Label = $CenterContainer/HBoxContainer/TextureRect/Label
@onready var faster_dig: Label = $CenterContainer/HBoxContainer/TextureRect2/Label2
@onready var third_upgrade: Label = $CenterContainer/HBoxContainer/TextureRect3/Label3

var more_damage_cost: int = 1
var faster_dig_cost: int = 2
var third_upgrade_cost: int = 3

var more_damage_max_lvl = 3
var faster_dig_max_lvl = 3
var third_upgrade_max_lvl = 3

var more_damage_current_lvl = 0
var faster_dig_current_lvl = 0
var third_upgrade_current_lvl = 0


func _on_texture_rect_3_button_down() -> void:
	$CenterContainer/HBoxContainer/TextureRect3/Label3.label_settings.font_color = Color.BLACK


func _on_button_down(extra_arg_0: bool, extra_arg_1: int) -> void:
	var label
	match extra_arg_1:
		0:
			label = $CenterContainer/HBoxContainer/TextureRect/Label
		1:
			label = $CenterContainer/HBoxContainer/TextureRect2/Label2
		2:
			label = $CenterContainer/HBoxContainer/TextureRect3/Label3
	
	label.label_settings.font_color = Color.BLACK
