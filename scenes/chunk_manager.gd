extends Node2D
class_name ChunkManager

@export var chunk_scenes: Array[PackedScene] = [
	preload("res://scenes/chunks/chunk_0.tscn")
]

@export var move_speed: float = 3.0
@export var active_chunk_count: int = 3

var active_chunks: Array[Node2D] = []

func _ready() -> void:
	# Initialize chunks
	for i in range(active_chunk_count):
		spawn_chunk(Vector2(i * 640, 0))  # Adjust 800 to your chunk width

func _physics_process(_delta: float) -> void:
	for chunk in active_chunks:
		chunk.position.x -= move_speed
		
		# Recycle chunk if out of screen
		if chunk.position.x < -chunk.get_width():
			recycle_chunk(chunk)

func spawn_chunk(position: Vector2) -> void:
	# Get a random chunk scene
	var chunk_scene = chunk_scenes[randi() % chunk_scenes.size()]
	var new_chunk = chunk_scene.instantiate() as Node2D
	new_chunk.position = position
	
	# Add to scene and active list
	add_child(new_chunk)
	active_chunks.append(new_chunk)
	
	# Connect end trigger
	var end_trigger = new_chunk.get_node("ChunkEnd") as Area2D
	end_trigger.body_entered.connect(on_chunk_end_trigger)

func recycle_chunk(chunk: Node2D) -> void:
	# Move chunk to the end of the last active chunk
	var last_chunk = active_chunks.back()
	var new_x = last_chunk.position.x + last_chunk.get_width()
	chunk.position.x = new_x
	
	# Rearrange the list
	active_chunks.erase(chunk)
	active_chunks.append(chunk)

func on_chunk_end_trigger(body: Node2D) -> void:
	if body.name == "Player":
		# Spawn new chunk at the end of the current one
		var last_chunk = active_chunks.back()
		var spawn_pos = last_chunk.position.x + last_chunk.get_width()
		spawn_chunk(Vector2(spawn_pos, 0))
