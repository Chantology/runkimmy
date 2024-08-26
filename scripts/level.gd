extends Node2D

#game variables
const PLAYER_START_POS := Vector2i(28, -102)
const CAM_START_POS := Vector2i(576, -329)
var score : int
const SCORE_MODIFIER : int = 10
var speed : float
const START_SPEED : float = 10.0
const SPEED_MODIFIER : int = 5000
const MAX_SPEED : int = 25
var screen_size : Vector2i
var game_running : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size
	new_game()

func new_game():
	#reset the nodes
	score = 0
	show_score()
	game_running = false
	
	#reset the nodes
	$player.position = PLAYER_START_POS
	$player.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$ground.position = Vector2i (0,0)
	
	#reset HUD
	$HUD.get_node("GameStartLabel").show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if game_running:
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED

	#move player and camera	
		$player.position.x += speed
		$Camera2D.position.x += speed
		
		
		#update score
		score += speed
		show_score()
		
		#update ground position
		if $Camera2D.position.x - $ground.position.x > screen_size.x * 1.7:
			$ground.position.x += screen_size.x
	else: 
		if Input.is_action_just_pressed("ui_accept"):
			game_running = true
			$HUD.get_node("GameStartLabel").hide()

func show_score():
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score / SCORE_MODIFIER)
