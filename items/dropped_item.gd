extends RigidBody2D

const TILE_0020 = preload("res://assets/tile_0020.png")
const TILE_0021 = preload("res://assets/tile_0021.png")
const TILE_0022 = preload("res://assets/tile_0022.png")

@onready var sprite_2d: Sprite2D = $Sprite2D

func set_item(item_id: int):
	var item_img
	match item_id:
		2:
			item_img = TILE_0020
		3:
			item_img = TILE_0021
	sprite_2d.texture = item_img
