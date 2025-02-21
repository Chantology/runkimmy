class_name ChunkManager extends Node2D

var game: Game
@export var chunk_scenes: Array[PackedScene] = [
	preload("res://scenes/chunks/chunk_1.tscn"),
	preload("res://scenes/chunks/chunk_2.tscn"),
	preload("res://scenes/chunks/chunk_3.tscn")
]
@export var active_chunk_count: int = 3
@export var pool_size: int = 6  # Keep extra chunks for smooth transitions

var active_chunks: Array[Node2D] = []
var chunk_pool: Array[Node2D] = []  # Pool of reusable chunks

var chunk_speed_map = {
	2: [0],        
	2.05: [1, 2],  
}


func initialize(p_game: Game) -> void:
	game = p_game
	# Pre-instantiate chunks for reuse
	for i in range(pool_size):
		var chunk = chunk_scenes[i % chunk_scenes.size()].instantiate()
		chunk.visible = false
		chunk_pool.append(chunk)
		add_child(chunk)  # Add to scene but keep hidden
	for i in range(active_chunk_count):
		spawn_chunk(Vector2(i * 640, 0))  


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
		spawn_chunk(Vector2(spawn_pos, 0))


func spawn_chunk(p_position: Vector2) -> void:
	var chunk: Chunk
	if chunk_pool.size() > 0:
		chunk = chunk_pool.pop_front()  # Get from pool
	else:
		chunk = chunk_scenes[randi() % chunk_scenes.size()].instantiate()  
	
	chunk.position = p_position
	chunk.visible = true  # Reactivate chunk
	
	for collision in chunk.collision_shapes:
		collision.disabled = false
	
	active_chunks.append(chunk)


func recycle_chunk(chunk: Node2D) -> void:
	active_chunks.erase(chunk)
	
	for collision in chunk.collision_shapes:
		collision.disabled = true
	
	chunk.visible = false
	chunk.position = Vector2(-9999, -9999)  # Move offscreen
	chunk_pool.append(chunk)  # Return to pool
