class_name Pickup extends Area2D

@export var random_sprite: bool = true


func _ready() -> void:
	setup_sprite()


func setup_sprite() -> void:
	if not random_sprite:
		return
	
	$Sprite2D.texture = PickupManager.get_random_sprite()
