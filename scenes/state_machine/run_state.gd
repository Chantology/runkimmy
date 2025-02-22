class_name RunState extends State

var base_gravity: float = 980.0
@onready var particle_spawn_timer: Timer = $ParticleSpawnTimer

func enter() -> void:
	kimmy.play_animation("run")
	particle_spawn_timer.start()
	VfxManager.instantiate_run_particles(kimmy.global_position)


func exit() -> void:
	particle_spawn_timer.stop()


func process_state(_delta) -> void:
	if Input.is_action_pressed("jump"):
		if kimmy.game.started:
			state_machine.change_state(state_machine.jump_state)
	else:
		kimmy.velocity.y += base_gravity * get_physics_process_delta_time()


func on_particle_spawn_timer_timeout() -> void:
	VfxManager.instantiate_run_particles(kimmy.global_position)
