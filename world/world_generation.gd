@tool
extends Node2D

const WIDTH = 40
const HEIGHT = 60

@onready var break_sfx: AudioStreamPlayer2D = $BreakSFX

var break_sfx_array = [
	preload("res://assets/audio/sfx/break dirt.mp3"),
	preload("res://assets/audio/sfx/break stone.mp3"),
	preload("res://assets/audio/sfx/break iron.mp3"),
	preload("res://assets/audio/sfx/break component.mp3")
	]

var iron_noise = FastNoiseLite.new()
var copper_noise = FastNoiseLite.new()

var tile_healths := {}

@export var tile_map: TileMapLayer
@export var break_tile_map: TileMapLayer
@export_tool_button("generate world")
var button = debug_gen_world
@export var iron_noise_frequency: float = 0.1
@export var copper_noise_frequency: float = 0.1
@export var iron_noise_cap: float = 0.23
@export var copper_noise_cap: float = 0.23

func _ready() -> void:
	tile_map.clear()
	generate_world()

func debug_gen_world():
	tile_map.clear()
	generate_world()

func generate_world() -> void:
	iron_noise.seed = randi()
	iron_noise.frequency = iron_noise_frequency
	iron_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	
	copper_noise.seed = randi()
	copper_noise.frequency = copper_noise_frequency
	copper_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	
	var dirt_tiles: Array[Vector2i]
	var stone_tiles: Array[Vector2i]
	var iron_tiles: Array[Vector2i]
	var copper_tiles: Array[Vector2i]
	
	for x in WIDTH: 
		for y in HEIGHT:
			var pos = Vector2i(x, y)
			if y < 20:
				dirt_tiles.append(pos)
			elif y < 60:
				stone_tiles.append(pos)
				if copper_noise.get_noise_2d(x, y) > copper_noise_cap:
					copper_tiles.append(pos)
			if y < 3: continue
			if iron_noise.get_noise_2d(x, y) > iron_noise_cap + y * 0.003:
				iron_tiles.append(pos)
				
	tile_map.set_cells_terrain_connect(dirt_tiles, 0, 0)
	tile_map.set_cells_terrain_connect(stone_tiles, 0, 1)
	tile_map.set_cells_terrain_connect(iron_tiles, 0, 2)
	tile_map.set_cells_terrain_connect(copper_tiles, 0, 3)


func request_break_tile(player_pos: Vector2, break_offset: Vector2, damage: int) -> bool:
	var break_pos = player_pos + (break_offset * 16)
	var can_break = break_tile(break_pos, damage)
	return can_break


func break_tile(pos: Vector2, damage: int) -> bool:
	var tile_pos = tile_map.local_to_map(pos)
	var tile_data = tile_map.get_cell_tile_data(tile_pos)
	if tile_data == null: 
		return false  # No tile to break
	
	var terrain_data = tile_data.get_terrain()
	
	if not tile_healths.has(tile_pos):
		tile_healths[tile_pos] = get_tile_max_health(terrain_data)
		
	tile_healths[tile_pos] -= damage
	display_tile_health_ui(tile_pos, tile_healths[tile_pos])
	
	if tile_healths[tile_pos] <= 0:
		destroy_tile(tile_pos, terrain_data)
	
	return true

func get_tile_max_health(terrain_id: int) -> int:
	match terrain_id:
		0: return 2  # Dirt
		1: return 4  # Stone
		2: return 6  # Iron ore
		3: return 8  # Copper ore
	return 2  # Default health


func display_tile_health_ui(tile_pos: Vector2i, current_health: int):
	break_tile_map.set_cell(tile_pos, 4, Vector2i(current_health - 1, 0))


func destroy_tile(tile_pos: Vector2i, tile_id: int) -> void:
	tile_map.set_cells_terrain_connect([tile_pos], 0, -1, false)
	for cell_coord in break_tile_map.get_surrounding_cells(tile_pos):
		if break_tile_map.get_cell_source_id(cell_coord) != 4:
			break_tile_map.erase_cell(cell_coord)
	tile_healths.erase(tile_pos)
	play_break_sound(tile_pos, tile_id)
	
	if tile_id <= 1: return
	spawn_drop(tile_pos, tile_id)


func spawn_drop(tile_pos: Vector2i, tile_id: int) -> void:
	var drop_scene = load("res://items/dropped_item.tscn")
	var drop = drop_scene.instantiate()
	get_parent().add_child(drop)
	drop.global_position = tile_map.map_to_local(tile_pos)
	
	drop.set_item(tile_id)


func play_break_sound(tile_pos: Vector2i, tile_id: int) -> void:
	break_sfx.global_position = tile_map.map_to_local(tile_pos)
	break_sfx.stream = break_sfx_array[tile_id]
	break_sfx.play()


func distance_to_closest_tile_in_area(pos: Vector2, radius: int) -> float:
	var centre_pos = tile_map.local_to_map(pos)
	var closest_distace = radius
	
	for x in range(centre_pos.x - radius, centre_pos.x + radius + 1):
		for y in range(centre_pos.y - radius, centre_pos.y + radius + 1):
			var current_pos = Vector2(x,y)
			var cell_data: TileData = tile_map.get_cell_tile_data(current_pos)
			if cell_data == null:
				continue
			
			if cell_data.terrain != 0 and cell_data.terrain != 1:
				var distance = centre_pos.distance_to(current_pos)
				
				if distance < closest_distace:
					closest_distace = distance
					
	return closest_distace
