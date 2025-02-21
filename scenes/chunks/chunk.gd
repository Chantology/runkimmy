class_name Chunk extends Node2D

@onready var end_trigger: Node2D = $EndPosition
@onready var static_body: StaticBody2D = $StaticBody2D
@export var collision_shapes: Array[CollisionShape2D]


func _ready() -> void:
	for collision in collision_shapes:
		collision.disabled = true


func get_width() -> float:
	return end_trigger.position.x
