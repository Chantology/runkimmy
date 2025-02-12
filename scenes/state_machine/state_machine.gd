class_name StateMachine extends Node


var kimmy: Kimmy
var current_state: State

var run_state: RunState
var idle_state: IdleState
var jump_state: JumpState
var die_state: DieState


func initialize(p_kimmy: Kimmy) -> void:
	kimmy = p_kimmy
	
	run_state = load("res://scenes/state_machine/run_state.tscn").instantiate()
	add_child(run_state)
	idle_state = load("res://scenes/state_machine/idle_state.tscn").instantiate()
	add_child(idle_state)
	jump_state = load("res://scenes/state_machine/jump_state.tscn").instantiate()
	add_child(jump_state)
	die_state = load("res://scenes/state_machine/die_state.tscn").instantiate()
	add_child(die_state)
	
	run_state.kimmy = kimmy
	run_state.state_machine = self
	jump_state.kimmy = kimmy
	jump_state.state_machine = self
	die_state.kimmy = kimmy
	die_state.state_machine = self
	
	current_state = idle_state
	current_state.enter()


func change_state(new_state: State) -> void:
	current_state.exit()
	current_state = new_state
	current_state.enter()


func process_state(delta: float) -> void:
	current_state.process_state(delta)
