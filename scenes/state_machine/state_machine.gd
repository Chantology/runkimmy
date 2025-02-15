class_name StateMachine extends Node

@onready var state_debug_label: Label = $StateDebugLabel

var kimmy: Kimmy
var current_state: State

var run_state: RunState
var jump_state: JumpState
var double_jump_state: DoubleJumpState
var die_state: DieState


func initialize(p_kimmy: Kimmy) -> void:
	kimmy = p_kimmy
	
	run_state = load("res://scenes/state_machine/run_state.tscn").instantiate()
	add_child(run_state)
	jump_state = load("res://scenes/state_machine/jump_state.tscn").instantiate()
	add_child(jump_state)
	double_jump_state = load("res://scenes/state_machine/double_jump_state.tscn").instantiate()
	add_child(double_jump_state)
	die_state = load("res://scenes/state_machine/die_state.tscn").instantiate()
	add_child(die_state)
	
	run_state.kimmy = kimmy
	run_state.state_machine = self
	jump_state.kimmy = kimmy
	jump_state.state_machine = self
	double_jump_state.kimmy = kimmy
	double_jump_state.state_machine = self
	die_state.kimmy = kimmy
	die_state.state_machine = self
	
	current_state = run_state
	current_state.enter()


func change_state(new_state: State) -> void:
	current_state.exit()
	current_state = new_state
	state_debug_label.text = new_state.name
	current_state.enter()


func process_state(delta: float) -> void:
	current_state.process_state(delta)
