class_name Game extends Node2D


@onready var parallax_background: ParallaxBackground = $ParallaxBackground
var parallax_speed: float = 3


func _physics_process(_delta: float) -> void:
	parallax_background.scroll_offset.x -= parallax_speed
