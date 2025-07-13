class_name ChunkManager extends Node2D

var game: Game

@export var chunk_scenes: Array[PackedScene] = [
	preload("res://scenes/chunks/chunk_0.tscn"),
	preload("res://scenes/chunks/chunk_1.tscn"),
	preload("res://scenes/chunks/chunk_2.tscn"),
	preload("res://scenes/chunks/chunk_3.tscn"),
	preload("res://scenes/chunks/chunk_4.tscn"),
	preload("res://scenes/chunks/chunk_5.tscn"),
	preload("res://scenes/chunks/chunk_6.tscn"),
	preload("res://scenes/chunks/chunk_7.tscn"),
	preload("res://scenes/chunks/chunk_8.tscn"),
	preload("res://scenes/chunks/chunk_9.tscn"),
	preload("res://scenes/chunks/chunk_10.tscn"),
	preload("res://scenes/chunks/chunk_11.tscn"),
	preload("res://scenes/chunks/chunk_12.tscn"),
	preload("res://scenes/chunks/chunk_13.tscn"),
	preload("res://scenes/chunks/chunk_14.tscn"),
	preload("res://scenes/chunks/chunk_15.tscn"),
	preload("res://scenes/chunks/chunk_16.tscn"),
	preload("res://scenes/chunks/chunk_17.tscn"),
	preload("res://scenes/chunks/chunk_18.tscn"),
	preload("res://scenes/chunks/chunk_19.tscn"),
	preload("res://scenes/chunks/chunk_20.tscn"),
]

@export var active_chunk_count: int = 3
@export var pool_size: int = 6  # Keep extra chunks for smooth transitions

var active_chunks: Array[Chunk] = []
var chunk_pool: Array[Chunk] = []  # Pool of reusable chunks

var speed_thresholds_dictionary: Dictionary = {
	2.0: [1],
	2.01: [2, 3, 4, 20],
	3: [2, 3, 4, 5, 15],
	4: [4, 5, 6, 7, 15],
	6: [6, 7, 8, 9, 14, 15],
	8: [8, 9, 10, 11, 15],
	10: [10, 11, 12, 13, 15],
	12: [5, 6, 14, 15],
	14: [5, 6, 15, 19],
	16: [5, 6, 15, 20],
	18: [5, 6, 15, 16],
	20: [5, 6, 14, 15],
	22: [5, 6, 15, 18],
	24: [5, 6, 15, 17],
	26: [5, 6, 14, 15],
	28: [5, 6, 15, 19],
}

var speed_thresholds: Array [SpeedThreshold] = []
var available_indices: Array = []


func initialize(p_game: Game) -> void:
	game = p_game
	
	initialize_speed_thresholds()
	
	# Pre-instantiate chunks for reuse
	for i in range(pool_size):
		var chunk: Chunk = chunk_scenes[0].instantiate()
		chunk.visible = false
		chunk_pool.append(chunk)
		add_child(chunk)  # Add to scene but keep hidden
		chunk.index = 0
	
	for i in range(active_chunk_count):
		spawn_chunk(Vector2(i * 640, 0))


func initialize_speed_thresholds() -> void:
	for speed_threshold in speed_thresholds_dictionary:
		speed_thresholds.append(SpeedThreshold.new(speed_threshold, speed_thresholds_dictionary[speed_threshold]))
	
	speed_thresholds.sort_custom(func(a, b): return a.min_speed < b.min_speed)


func _physics_process(delta: float) -> void:
	if game.over:
		return
	
	for chunk in active_chunks:
		chunk.position.x -= game.speed
		
		if chunk.position.x < -chunk.get_width() - 10:
			call_deferred("recycle_chunk", chunk)
	
	if active_chunks.size() < active_chunk_count:
		var last_chunk = active_chunks.back()
		var spawn_pos = last_chunk.position.x + last_chunk.get_width()
		call_deferred("spawn_chunk", Vector2(spawn_pos, 0))


func spawn_chunk(p_position: Vector2) -> void:
	var chunk: Chunk
	available_indices = get_available_chunk_indices()
	
	if chunk_pool.size() > 0:
		chunk = chunk_pool.pop_front()  # Get from pool
	else:
		var chunk_index: int = available_indices[randi() % available_indices.size()]
		print(chunk_index)
		chunk = chunk_scenes[chunk_index].instantiate()
		call_deferred("add_new_chunk", chunk, p_position, chunk_index)
		return
	
	chunk.position = p_position
	chunk.visible = true  # Reactivate chunk
	
	for collision in chunk.collision_shapes:
		collision.disabled = false
	
	active_chunks.append(chunk)


func add_new_chunk(chunk: Chunk, p_position: Vector2, chunk_index: int) -> void:
	add_child(chunk)
	chunk.index = chunk_index
	chunk.position = p_position
	chunk.visible = true
	
	for collision in chunk.collision_shapes:
		collision.disabled = false
	
	active_chunks.append(chunk)


func recycle_chunk(chunk: Chunk) -> void:
	active_chunks.erase(chunk)
	
	for collision in chunk.collision_shapes:
		collision.disabled = true
	
	chunk.visible = false
	chunk.position = Vector2(-9999, -9999)  # Move offscreen
	if available_indices.has(chunk.index):
		if chunk.index == 0 and game.started:
			return
		chunk_pool.append(chunk)  # Return to pool only if it's on the available chunks list


func get_available_chunk_indices() -> Array:
	var current_speed: float = game.speed
	var available_indices: Array = []
	
	# Find the highest threshold that's below or equal to current speed
	for threshold in speed_thresholds:
		if current_speed >= threshold.min_speed:
			available_indices = threshold.chunk_indices
			if game.started and threshold.chunk_indices == [0]: # This is such an ugly patch. But it works :-)
				available_indices = [1, 2, 3]
	
	return available_indices


func on_game_start() -> void:
	# Keep only chunks that are visible on screen
	# We'll keep the first 1-2 chunks
	var chunks_to_keep: Array[Chunk] = []
	
	# Only keep the first 2 active chunks, which should be what's visible
	var visible_chunks_count = min(2, active_chunks.size())
	
	for i in range(active_chunks.size()):
		if i < visible_chunks_count:
			chunks_to_keep.append(active_chunks[i])
		else:
			# Remove chunks beyond what's visible
			active_chunks[i].queue_free()
	
	# Replace active_chunks with only the chunks we want to keep
	active_chunks = chunks_to_keep
	
	# Clear the entire chunk pool since these aren't visible
	for chunk in chunk_pool:
		chunk.queue_free()
	
	# Reset the pool to empty
	chunk_pool = []
