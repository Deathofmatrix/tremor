extends Camera2D

@export var player: CharacterBody2D

@export var smoothing_enbled: bool
@export_range(1, 10) var smoothing_distance: int = 8

func _physics_process(delta: float) -> void:
	if player != null:
		var camera_position: Vector2
		
		if smoothing_enbled:
			var weight: float = float(smoothing_distance) / 100
			camera_position = lerp(global_position, player.global_position, weight)
		else:
			camera_position = player.global_position
		
		global_position = camera_position
