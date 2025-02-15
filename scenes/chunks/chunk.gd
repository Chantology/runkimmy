class_name Chunk extends Node2D


@onready var end_trigger: Area2D = $EndPosition


func get_width() -> float:
	return end_trigger.position.x
