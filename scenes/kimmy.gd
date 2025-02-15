class_name Kimmy extends CharacterBody2D

signal died

@onready var state_machine: StateMachine = $StateMachine
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

var dead: bool = false


func _ready() -> void:
	state_machine.initialize(self)


func _physics_process(delta: float) -> void:
	if is_on_wall():
		if get_last_slide_collision().get_position() > position:
			die()
	state_machine.process_state(delta)
	move_and_slide()


func play_animation(animation_name: String) -> void:
	animation_player.play(animation_name)


func die() -> void:
	if not dead:
		dead = true
		state_machine.change_state(state_machine.die_state)
		$CollisionShape2D.shape.height = 30
		died.emit()
