extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -800.0

var jump_max = 2
var jump_count = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		if not get_parent().game_running:
			$AnimatedSprite2D.play("idle")
		else: 
			velocity.y += gravity * delta
			jump_count = 0

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and jump_count < jump_max:
		jump_count += 1
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var direction = Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		
#Play animations
	if is_on_floor():
		animated_sprite.play("run")
	else: 
		animated_sprite.play("jump")

	move_and_slide()
