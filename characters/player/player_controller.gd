class_name Player
extends CharacterBody2D

const SPEED = 50.0
const JUMP_VELOCITY = -160.0

@onready var mine_timer: Timer = $MineTimer
@onready var tilemaps: Node2D = $"../Tilemaps"
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var stamina_progress_bar: ProgressBar = $"../CanvasLayer/HUD/StaminaProgressBar"

@export var money = 0

var distance_to_tile: float = 0.0
var focus_distance: float = 6.0
var is_heartbeat_active: bool = false
var camera: PlayerCamera

var is_underground: bool = false
var input_direction: Vector2

var mine_cooldown: float = 1
var mine_power: int = 1
var speed_multiplier: float = 1

var current_stamina: float = 0
var max_stamina: float = 100
var exhaust_multiplier = 1
var is_exhausted = false


func _ready() -> void:
	camera = get_viewport().get_camera_2d() as PlayerCamera
	mine_timer.wait_time = mine_cooldown
	set_money(money)
	current_stamina = max_stamina
	stamina_progress_bar.max_value = max_stamina


func _process(delta: float) -> void:
	if Input.is_action_pressed("interact") and mine_timer.is_stopped() and is_exhausted == false:
		handle_breaking()
		mine_timer.start()
		progress_bar.max_value = mine_cooldown
	
	if Input.is_action_just_pressed("focus"):
		is_heartbeat_active = true
		distance_to_tile = tilemaps.distance_to_closest_tile_in_area(position, focus_distance)
		var heartbeat_speed = remap(distance_to_tile, 0, focus_distance, 5.0, 1.0)
		camera.start_heartbeat(heartbeat_speed)
	
	if Input.is_action_just_released("focus"):
		is_heartbeat_active = false
		camera.stop_heartbeat()
	
	progress_bar.value = mine_timer.time_left


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	handle_movement()
	if is_heartbeat_active: velocity = Vector2.ZERO
	move_and_slide()


func handle_movement() -> void:
	if not is_underground:
		if input_direction.x:
			velocity.x = input_direction.x * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	elif is_underground:
		if input_direction:
			velocity = input_direction * SPEED * speed_multiplier * exhaust_multiplier
		else:
			velocity = Vector2.ZERO


func handle_breaking() -> void:
	var tile_map = $"../Tilemaps"
	
	var break_offset = Vector2.ZERO
	if input_direction.x != 0:
		break_offset = Vector2(input_direction.x, 0)
	elif input_direction.y != 0:
		break_offset = Vector2(0, input_direction.y)
	
	if break_offset == Vector2.ZERO:
		return  # No directional input, no breaking
	
	var can_break = tile_map.request_break_tile(global_position, break_offset, mine_power)
	if can_break:
		use_stamina(5)


func set_money(value:int):
	money = value
	$"../CanvasLayer/HUD/Label".text = str(money)


func use_stamina(value: float) -> void:
	current_stamina -= value
	stamina_progress_bar.value = current_stamina
	if current_stamina <= 0:
		exhaust_multiplier = 0.3
		is_exhausted = true


func apply_upgrade(upgrade_name: String):
	match upgrade_name:
		"more_damage": mine_power += 1
		"faster_dig": 
			mine_cooldown -= 0.3
			mine_timer.wait_time = mine_cooldown
		"faster_move": speed_multiplier += 0.5
		"refill_stamina": 
			current_stamina = max_stamina
			stamina_progress_bar.value = max_stamina
			exhaust_multiplier = 1
			is_exhausted = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("drops"):
		set_money(money + body.value)
		body.queue_free()
