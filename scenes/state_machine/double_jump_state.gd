class_name DoubleJumpState extends State

const DOUBLE_JUMP_FORCE: float = -450.0  # Slightly weaker for better game feel
const JUMP_CUT_MULTIPLIER: float = 0.3
const FALL_GRAVITY_MULTIPLIER: float = 2
const BASE_GRAVITY: float = 980.0

var double_jump_force: float = DOUBLE_JUMP_FORCE
var spin_duration: float = 0.35


func enter() -> void:
	kimmy.play_animation("jump")
	kimmy.velocity.y = double_jump_force
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(kimmy.sprite, "rotation_degrees", 360, spin_duration)


func exit() -> void:
	kimmy.sprite.rotation_degrees = 0


func handle_input() -> void:
	if not Input.is_action_pressed("jump") and kimmy.velocity.y < 0:
		kimmy.velocity.y *= JUMP_CUT_MULTIPLIER


func process_state(_delta: float) -> void:
	var gravity = BASE_GRAVITY
	
	if kimmy.velocity.y > 0 or not Input.is_action_pressed("jump"):
		gravity *= FALL_GRAVITY_MULTIPLIER
	
	kimmy.velocity.y += gravity * get_physics_process_delta_time()
	
	if kimmy.is_on_floor():
		state_machine.change_state(state_machine.run_state)
