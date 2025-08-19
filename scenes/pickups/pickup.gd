class_name Pickup extends Area2D

@export var random_sprite: bool = true


func _ready() -> void:
	setup_sprite()


func setup_sprite() -> void:
	if not random_sprite:
		return
	
	$Sprite2D.texture = PickupManager.get_random_sprite()


func on_body_entered(body: Node2D) -> void:
	if body is Kimmy:
		print("Kimmy picked me up!")
		ScoreManager.additional_score += 100
		VfxManager.instantiate_pickup_particles(global_position)
		Audio.play_sound("CollectStar", 1)
		hide()
