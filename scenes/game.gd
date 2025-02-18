class_name Game extends Node2D


@onready var parallax_background: ParallaxBackground = $ParallaxBackground

const INITIAL_SPEED: float = 2.0
const MAX_SPEED: float = 30.0
const ACCELERATION: float = 0.05

var speed: float = INITIAL_SPEED
var distance_score: float = 0.0
var additional_score: float = 0.0 # score we get from collectibles and stuff

var started: bool = false
var over: bool = false

@onready var chunk_manager: ChunkManager = $ChunkManager
@onready var kimmy: Kimmy = $Kimmy

# USER_INTERFACE
@onready var music_button: TextureButton = %MusicButton
@onready var sound_button: TextureButton = %SoundButton
@onready var ui_animation_player: AnimationPlayer = %UIAnimationPlayer


func _ready() -> void:
	chunk_manager.initialize(self)
	kimmy.game = self
	kimmy.died.connect(on_game_over)
	setup_menu()


func _physics_process(delta: float) -> void:
	if over:
		return
	
	parallax_background.scroll_offset.x -= speed
	
	if speed < MAX_SPEED and started: # only increase speed if the game already started
		speed = min(MAX_SPEED, speed + ACCELERATION * delta)
	
	distance_score += speed * delta # we can add a modifier here


func restart_game() -> void:
	speed = INITIAL_SPEED
	distance_score = 0.0
	additional_score = 0.0


func on_game_over() -> void:
	over = true


func setup_menu() -> void:
	Audio.play_music("menu")
	ui_animation_player.play("start_menu_in")
	
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
		Audio.play_music("game")
