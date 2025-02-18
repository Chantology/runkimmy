class_name RunState extends State

var base_gravity: float = 980.0

func enter() -> void:
	kimmy.play_animation("run")


func exit() -> void:
	pass


func process_state(_delta) -> void:
	if Input.is_action_pressed("jump"):
		if kimmy.game.started:
			state_machine.change_state(state_machine.jump_state)
	else:
		kimmy.velocity.y += base_gravity * get_physics_process_delta_time()
