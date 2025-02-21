class_name Chunk extends Node2D

@onready var end_trigger: Node2D = $EndPosition
@onready var static_body: StaticBody2D = $StaticBody2D


func get_width() -> float:
	return end_trigger.position.x


func deactivate() -> void:
	pass


func activate() -> void:
	pass
