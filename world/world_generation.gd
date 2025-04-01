@tool
extends Node2D

const WIDTH = 40
const HEIGHT = 60

var iron_noise = FastNoiseLite.new()
var copper_noise = FastNoiseLite.new()

@export var tile_map: TileMapLayer
@export_tool_button("generate world")
var button = debug_gen_world
@export var iron_noise_frequency: float = 0.1
@export var iron_noise_cap: float = 0.23

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
	copper_noise.frequency = 0.1
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
			if y < 3: continue
			if iron_noise.get_noise_2d(x, y) < -iron_noise_cap:
				iron_tiles.append(pos)
			#if copper_noise.get_noise_2d(x, y) > 0.9:
				#copper_tiles.append(Vector2i(x, y))
			
	tile_map.set_cells_terrain_connect(dirt_tiles, 0, 0)
	tile_map.set_cells_terrain_connect(stone_tiles, 0, 1)
	tile_map.set_cells_terrain_connect(iron_tiles, 0, 2)
	#tile_map.set_cells_terrain_connect(copper_tiles, 0, 3)


func break_tile(pos: Vector2) -> void:
	tile_map.set_cells_terrain_connect([tile_map.local_to_map(pos)], 0, -1, true)
