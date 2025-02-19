class_name ChunkManager extends Node2D

var game: Game

@export var chunk_scenes: Array[PackedScene] = [
	preload("res://scenes/chunks/chunk_1.tscn"),
	preload("res://scenes/chunks/chunk_1b.tscn"),
	preload("res://scenes/chunks/chunk_2.tscn"),
	preload("res://scenes/chunks/chunk_3.tscn")
]

var instantiated_chunks: Array[Chunk] = []
var hidden_chunk_position: Vector2 = Vector2(0, -360)
var last_spawned_chunk: Chunk

@export var active_chunk_count: int = 2
var active_chunks: Array[Node2D] = []

var chunk_speed_map = {
	2: [0, 1],               # Only chunk_0 when speed is 2
	2.05: [2, 3],           # chunk_0 and chunk_1 when speed is 10
}


func initialize(p_game: Game) -> void:
	game = p_game
	process_priority = 1
	instantiate_chunks()
	for i in range(active_chunk_count):
		spawn_chunk(Vector2(i * 640, 0))  # Adjust 640 to your chunk width


func _physics_process(_delta: float) -> void:
	if game.over:
		return
	
	for chunk in active_chunks:
		chunk.position.x -= game.speed
		
		# Destroy chunk if out of screen
		if chunk.position.x < -chunk.get_width():
			active_chunks.erase(chunk)
			chunk.deactivate()
			chunk.global_transform.origin = hidden_chunk_position
		
	# Check if we need a new chunk
	if active_chunks.size() < active_chunk_count:
		var last_chunk = active_chunks.back()
		var spawn_pos = last_chunk.position.x + last_chunk.get_width()
		spawn_chunk(Vector2(spawn_pos, 0))


func spawn_chunk(p_position: Vector2) -> void:
	# Choose chunks based on current speed
	var selected_chunks: Array = get_chunks_for_speed(game.speed)
	var chunk: Chunk = instantiated_chunks[selected_chunks[randi() % selected_chunks.size()]]
	
	while chunk == last_spawned_chunk: # Make sure we don't repeat the same chunk twice in a row.
		chunk = instantiated_chunks[selected_chunks[randi() % selected_chunks.size()]]
	
	chunk.activate()
	
	chunk.global_transform.origin = p_position
	active_chunks.append(chunk)
	last_spawned_chunk = chunk


func get_chunks_for_speed(speed: float) -> Array:
	# Find the closest speed range without exceeding the current speed
	var selected_chunks = []
	for key in chunk_speed_map.keys():
		if speed >= key:
			selected_chunks = chunk_speed_map[key]
	return selected_chunks


func instantiate_chunks() -> void:
	for chunk in chunk_scenes:
		var new_chunk: Chunk = chunk.instantiate()
		add_child(new_chunk)
		instantiated_chunks.append(new_chunk)
		new_chunk.global_position = hidden_chunk_position
