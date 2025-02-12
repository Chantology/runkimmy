class_name JumpState extends State

const JUMP_FORCE: float = -550.0
const JUMP_CUT_MULTIPLIER: float = 0.3
const FALL_GRAVITY_MULTIPLIER: float = 4
const BASE_GRAVITY: float = 980.0

var jump_force: float = JUMP_FORCE
var jump_cut_multiplier: float = JUMP_CUT_MULTIPLIER
var fall_gravity_multiplier: float = FALL_GRAVITY_MULTIPLIER
var base_gravity: float = BASE_GRAVITY


func enter() -> void:
	kimmy.play_animation("jump_" + kimmy.hair_state)
	kimmy.velocity.y = jump_force


func exit() -> void:
	pass


func handle_input() -> void:
	if not Input.is_action_pressed("jump") and kimmy.velocity.y < 0:
		kimmy.velocity.y *= jump_cut_multiplier


func process_state(_delta: float) -> void:
	var gravity = base_gravity
	
	if kimmy.velocity.y > 0 or not Input.is_action_pressed("jump"):
		gravity *= fall_gravity_multiplier
	
	kimmy.velocity.y += gravity * get_physics_process_delta_time()
	
	if kimmy.is_on_floor():
		if Input.is_action_pressed("jump"):
			state_machine.change_state(state_machine.jump_state)
		else:
			state_machine.change_state(state_machine.run_state)
