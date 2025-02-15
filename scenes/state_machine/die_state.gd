class_name DieState extends State

var base_gravity: float = 245.0

func enter() -> void:
	kimmy.play_animation("jump")
	kimmy.velocity.y = 0
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(kimmy.sprite, "rotation_degrees", 90, 0.25)


func exit() -> void:
	pass


func process_state(_delta) -> void:
	kimmy.velocity.y += base_gravity * get_physics_process_delta_time()
