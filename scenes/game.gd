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


func _ready() -> void:
	chunk_manager.initialize(self)
	kimmy.game = self
	kimmy.died.connect(on_game_over)


func _physics_process(delta: float) -> void:
	if over:
		return
	
	parallax_background.scroll_offset.x -= speed
	
	if speed < MAX_SPEED:
		speed = min(MAX_SPEED, speed + ACCELERATION * delta)
	
	distance_score += speed * delta # we can add a modifier here


func restart_game() -> void:
	speed = INITIAL_SPEED
	distance_score = 0.0
	additional_score = 0.0


func on_game_over() -> void:
	over = true
