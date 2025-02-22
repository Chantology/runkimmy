extends Node2D

var game: Game
@export var jump_animated_sprite_scene: PackedScene
@export var run_animated_sprite_scene: PackedScene
@export var pickup_animated_sprite_scene: PackedScene
@export var pickup_particles_scene: PackedScene

var active_vfx: Array = []

func instantiate_jump_particles(p_global_position: Vector2) -> void:
	var jump_vfx: AnimatedSprite2D = jump_animated_sprite_scene.instantiate()
	add_child(jump_vfx)
	active_vfx.append(jump_vfx)
	jump_vfx.global_position = p_global_position
	jump_vfx.play("default")
	await jump_vfx.animation_finished
	active_vfx.erase(jump_vfx)
	jump_vfx.queue_free()


func instantiate_run_particles(p_global_position: Vector2) -> void:
	var run_vfx: AnimatedSprite2D = run_animated_sprite_scene.instantiate()
	add_child(run_vfx)
	active_vfx.append(run_vfx)
	run_vfx.global_position = p_global_position - Vector2(4, 6)
	run_vfx.play("default")
	await run_vfx.animation_finished
	active_vfx.erase(run_vfx)
	run_vfx.queue_free()


func instantiate_pickup_particles(p_global_position: Vector2) -> void:
	var pickup_vfx: AnimatedSprite2D = pickup_animated_sprite_scene.instantiate()
	add_child(pickup_vfx)
	active_vfx.append(pickup_vfx)
	pickup_vfx.global_position = p_global_position
	pickup_vfx.play("default")
	await pickup_vfx.animation_finished
	active_vfx.erase(pickup_vfx)
	pickup_vfx.queue_free()


#func instantiate_pickup_particles(p_global_position: Vector2) -> void:
	#var pickup_particles: CPUParticles2D = pickup_particles_scene.instantiate()
	#add_child(pickup_particles)
	#active_vfx.append(pickup_particles)
	#pickup_particles.global_position = p_global_position
	#pickup_particles.emitting = true
	#await pickup_particles.finished
	#active_vfx.erase(pickup_particles)
	#pickup_particles.queue_free()


func _physics_process(delta: float) -> void:
	if game.over:
		return
	
	for vfx in active_vfx:
		vfx.position.x -= game.speed
