class_name Game extends Node2D


@onready var parallax_background: ParallaxBackground = $ParallaxBackground

const INITIAL_SPEED: float = 2.0
const MAX_SPEED: float = 30.0
const ACCELERATION: float = 0.08

var speed: float = INITIAL_SPEED

var can_start: bool = false
var started: bool = false
var over: bool = false

@onready var chunk_manager: ChunkManager = $ChunkManager
@onready var kimmy: Kimmy = $Kimmy

# USER_INTERFACE
@onready var music_button: TextureButton = %MusicButton
@onready var sound_button: TextureButton = %SoundButton
@onready var ui_animation_player: AnimationPlayer = %UIAnimationPlayer
@onready var score_label: Label = %ScoreLabel
@onready var high_score_label: Label = %HighScoreLabel


func _ready() -> void:
	VfxManager.game = self
	chunk_manager.initialize(self)
	kimmy.game = self
	kimmy.died.connect(on_game_over)
	setup_menu()


func _process(delta: float) -> void:
	if over:
		return
	
	parallax_background.scroll_base_offset.x -= speed
	
	if speed < MAX_SPEED and started: # only increase speed if the game already started
		speed = min(MAX_SPEED, speed + ACCELERATION * delta)
	
	ScoreManager.distance_score += speed * delta * ScoreManager.score_speed
	var score_text: String = ScoreManager.get_score_as_string()
	score_label.text = "SCORE: " + score_text
	if ScoreManager.distance_score + ScoreManager.additional_score > ScoreManager.high_score:
		high_score_label.text = "HIGH SCORE: " + score_text


func restart_game() -> void:
	speed = INITIAL_SPEED
	ScoreManager.distance_score = 0.0
	ScoreManager.additional_score = 0.0
	over = false
	ScoreManager.load_high_score()


func on_game_over() -> void:
	over = true
	var final_score: float = ScoreManager.distance_score + ScoreManager.additional_score
	
	if final_score > ScoreManager.high_score:
		ScoreManager.high_score = final_score
		ScoreManager.save_high_score()
	
	ui_animation_player.play("game_over_in")


func setup_menu() -> void:
	high_score_label.text = "HIGH SCORE: " + str(int(ScoreManager.high_score))
	Audio.play_music("menu")
	ui_animation_player.play("start_menu_in")
	Audio.play_sound("woosh")
	if Audio.is_music_muted:
		music_button.set_pressed_no_signal(true)
	
	if Audio.is_sound_muted:
		music_button.set_pressed_no_signal(true)
	await ui_animation_player.animation_finished
	can_start = true


func on_music_button_toggled(_toggled_on: bool) -> void:
	Audio.toggle_music_mute()


func on_sound_button_toggled(_toggled_on: bool) -> void:
	Audio.toggle_sound_mute()


func on_start_button_pressed() -> void:
	if not started and not over and can_start:
		chunk_manager.on_game_start()
		started = true
		ui_animation_player.play("start_menu_out")
		Audio.play_sound("woosh")
		Audio.play_music("game")
		await ui_animation_player.animation_finished
		ui_animation_player.play("gameplay_in")


func on_restart_button_pressed() -> void:
	restart_game()
	
	var tree := get_tree()
	var scene_path := tree.current_scene.scene_file_path
	tree.call_deferred("unload_current_scene")
	tree.call_deferred("change_scene_to_file", scene_path)
