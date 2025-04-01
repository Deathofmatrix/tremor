class_name Player
extends CharacterBody2D

const SPEED = 50.0
const JUMP_VELOCITY = -160.0

@onready var timer: Timer = $Timer

var is_underground: bool = false
var input_direction: Vector2

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and timer.is_stopped():
		handle_breaking()
		timer.start()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	handle_movement()
	move_and_slide()


func handle_movement() -> void:
	if not is_underground:
		if input_direction.x:
			velocity.x = input_direction.x * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	elif is_underground:
		if input_direction:
			velocity = input_direction * SPEED
		else:
			velocity = Vector2.ZERO


func handle_breaking() -> void:
	$"../Tilemaps".break_tile(global_position + (input_direction * 16))
