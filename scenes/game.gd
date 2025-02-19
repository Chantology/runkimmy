class_name Game extends Node2D


@onready var parallax_background: ParallaxBackground = $ParallaxBackground

const INITIAL_SPEED: float = 2.0
const MAX_SPEED: float = 30.0
const ACCELERATION: float = 0.05

var speed: float = INITIAL_SPEED

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

# SCORE
const SAVE_FILE = "user://highscore.save"
const CONFIG_SECTION = "game"
const HIGH_SCORE_KEY = "high_score"
var distance_score: float = 0.0
var additional_score: float = 0.0 # score we get from collectibles and stuff
var high_score: float = 0.0
var score_speed: float = 3.0


func _ready() -> void:
	chunk_manager.initialize(self)
	kimmy.game = self
	kimmy.died.connect(on_game_over)
	load_high_score()
	setup_menu()


func _process(delta: float) -> void:
	if over:
		return
	
	parallax_background.scroll_base_offset.x -= speed
	
	if speed < MAX_SPEED and started: # only increase speed if the game already started
		speed = min(MAX_SPEED, speed + ACCELERATION * delta)
	
	distance_score += speed * delta * score_speed
	var score_text: String = str(int(distance_score + additional_score))
	score_label.text = "SCORE: " + score_text
	if distance_score + additional_score > high_score:
		high_score_label.text = "HIGH SCORE: " + score_text


func restart_game() -> void:
	speed = INITIAL_SPEED
	distance_score = 0.0
	additional_score = 0.0
	over = false
	load_high_score()


func on_game_over() -> void:
	over = true
	var final_score: float = distance_score + additional_score
	
	if final_score > high_score:
		high_score = final_score
		save_high_score()


func setup_menu() -> void:
	Audio.play_music("menu")
	ui_animation_player.play("start_menu_in")
	Audio.play_sound("woosh")
	
	if Audio.is_music_muted:
		music_button.set_pressed_no_signal(true)
	
	if Audio.is_sound_muted:
		music_button.set_pressed_no_signal(true)


func on_music_button_toggled(_toggled_on: bool) -> void:
	Audio.toggle_music_mute()


func on_sound_button_toggled(_toggled_on: bool) -> void:
	Audio.toggle_sound_mute()


func on_start_button_pressed() -> void:
	if not started and not over:
		started = true
		ui_animation_player.play("start_menu_out")
		Audio.play_sound("woosh")
		Audio.play_music("game")
		await ui_animation_player.animation_finished
		ui_animation_player.play("gameplay_in")


func load_high_score() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_FILE)
	
	if err == OK:
		high_score = config.get_value(CONFIG_SECTION, HIGH_SCORE_KEY, 0.0)
	else:
		high_score = 0.0
	
	high_score_label.text = "HIGH SCORE: " + str(int(high_score))


func save_high_score() -> void:
	var config = ConfigFile.new()
	config.set_value(CONFIG_SECTION, HIGH_SCORE_KEY, high_score)
	config.save(SAVE_FILE)
