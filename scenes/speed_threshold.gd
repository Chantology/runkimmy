class_name SpeedThreshold extends Node

var min_speed: float
var chunk_indices: Array

func _init(p_min_speed: float, p_chunk_indices: Array) -> void:
	min_speed = p_min_speed
	chunk_indices = p_chunk_indices
