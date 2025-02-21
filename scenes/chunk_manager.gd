class_name ChunkManager extends Node2D

var game: Game

@export var chunk_scenes: Array[PackedScene] = [
	preload("res://scenes/chunks/chunk_1.tscn"),
	preload("res://scenes/chunks/chunk_2.tscn"),
	preload("res://scenes/chunks/chunk_3.tscn")
]

@export var active_chunk_count: int = 3

var active_chunks: Array[Node2D] = []

var chunk_speed_map = {
	2: [0],               # Only chunk_0 when speed is 2
	2.05: [1, 2],           # chunk_0 and chunk_1 when speed is 10
}


func initialize(p_game: Game) -> void:
	game = p_game


	for i in range(active_chunk_count):
		spawn_chunk(Vector2(i * 640, 0))  # Adjust 640 to your chunk width


func _process(_delta: float) -> void:
	if game.over:
		return
	
	for chunk in active_chunks:
		chunk.position.x -= game.speed
		
		# Destroy chunk if out of screen
		if chunk.position.x < -chunk.get_width() - 10:
			chunk.queue_free()
			active_chunks.erase(chunk)
		
	# Check if we need a new chunk
	if active_chunks.size() < active_chunk_count:
		var last_chunk = active_chunks.back()
		var spawn_pos = last_chunk.position.x + last_chunk.get_width()
		spawn_chunk(Vector2(spawn_pos, 0))


func spawn_chunk(p_position: Vector2) -> void:
	# Choose chunks based on current speed
	var selected_chunks: Array = get_chunks_for_speed(game.speed)
	var chunk_scene: PackedScene = chunk_scenes[selected_chunks[randi() % selected_chunks.size()]]
	var new_chunk: Chunk = chunk_scene.instantiate()
	new_chunk.position = p_position
	
	add_child(new_chunk)
	active_chunks.append(new_chunk)


func get_chunks_for_speed(speed: float) -> Array:
	# Find the closest speed range without exceeding the current speed
	var selected_chunks = []
	for key in chunk_speed_map.keys():
		if speed >= key:
			selected_chunks = chunk_speed_map[key]
	return selected_chunks
