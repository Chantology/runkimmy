class_name Kimmy extends CharacterBody2D

signal died
signal obstacle_hit(obstacle: Obstacle)

var game: Game
@onready var state_machine: StateMachine = $StateMachine
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_area: Area2D = $CollisionArea

var dead: bool = false

func _ready() -> void:
	state_machine.initialize(self)
	collision_area.body_entered.connect(_on_collision_area_body_entered)


func _physics_process(delta: float) -> void:
	state_machine.process_state(delta)
	
	velocity.x = 0
	
	move_and_slide()


func _on_collision_area_body_entered(body: Node2D) -> void:
	if dead:
		return
	
	if body == self:
		return
	
	if body is Obstacle:
		print("Collided with obstacle!")
		handle_obstacle_collision(body)
	#else: # I collided with a platform!
		#if not is_on_floor():
			#print("not on floor")
			#die()


func play_animation(animation_name: String) -> void:
	animation_player.play(animation_name)


func handle_obstacle_collision(obstacle: Obstacle) -> void:
	obstacle.set_deferred("freeze", false) # This can't be done in the same physics frame.
	await get_tree().physics_frame         # So we do it, then wait for the frame to end before applying forces.
	await get_tree().process_frame
	
	var impact_force: float = game.speed * 50
	var force_direction = (obstacle.global_position - global_position).normalized()
	force_direction.y = -0.5
	force_direction = force_direction.normalized()
	
	obstacle.apply_central_impulse(force_direction * impact_force) # Apply force
	obstacle.apply_torque_impulse(randf_range(-100.0, 100.0))      # Apply rotation
	
	obstacle_hit.emit(obstacle)
	print("obstacle coll")
	die()


func die() -> void:
	print("died?")
	if not dead:
		dead = true
		state_machine.change_state(state_machine.die_state)
		died.emit() # This signal gets picked up in game.gd
