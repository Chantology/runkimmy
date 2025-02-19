class_name Chunk extends Node2D

@onready var end_trigger: Node2D = $EndPosition
@onready var static_body: StaticBody2D = $StaticBody2D


func get_width() -> float:
	return end_trigger.position.x


func deactivate() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	for child in get_children():
		if child is StaticBody2D:
			child.set_physics_process(false)
			child.set_physics_process_internal(false)
			if child.has_node("CollisionShape2D"):
				var collision = child.get_node("CollisionShape2D")
				collision.set_deferred("disabled", true)
	visible = false


func activate() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	for child in get_children():
		if child is StaticBody2D:
			child.set_physics_process(true)
			child.set_physics_process_internal(true)
			if child.has_node("CollisionShape2D"):
				var collision = child.get_node("CollisionShape2D")
				collision.set_deferred("disabled", false)
	visible = true
