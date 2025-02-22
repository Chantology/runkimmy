class_name JumpState extends State

const JUMP_FORCE: float = -500.0
const JUMP_CUT_MULTIPLIER: float = 0.3
const FALL_GRAVITY_MULTIPLIER: float = 2
const BASE_GRAVITY: float = 980.0

var jump_force: float = JUMP_FORCE


func enter() -> void:
	kimmy.play_animation("jump")
	kimmy.velocity.y = jump_force
	
	VfxManager.instantiate_jump_particles(kimmy.global_position)
	Audio.play_sound("jump")


func exit() -> void:
	pass


func process_state(_delta: float) -> void:
	var gravity = BASE_GRAVITY
	
	if kimmy.velocity.y > 0 or not Input.is_action_pressed("jump"):
		gravity *= FALL_GRAVITY_MULTIPLIER
	
	kimmy.velocity.y += gravity * get_physics_process_delta_time()
	
	if kimmy.is_on_floor():
		if Input.is_action_pressed("jump"):
			state_machine.change_state(state_machine.jump_state)
		else:
			state_machine.change_state(state_machine.run_state)
	else:
		if Input.is_action_just_pressed("jump"):
			state_machine.change_state(state_machine.double_jump_state)
