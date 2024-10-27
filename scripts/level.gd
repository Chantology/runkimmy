extends Node2D

#preload obstacles
var barrel_scene = preload("res://scenes/props/barrel.tscn")
var bin_scene = preload("res://scenes/props/bin.tscn")
var cardboardbox_scene = preload("res://scenes/props/cardboardbox.tscn")
var container_scene = preload("res://scenes/props/container.tscn")
var crate_scene = preload("res://scenes/props/crate.tscn")
var foodstand_scene = preload("res://scenes/props/foodstand.tscn")
var garbagebag_scene = preload("res://scenes/props/garbagebag.tscn")
var trafficcone_scene = preload("res://scenes/props/trafficcone.tscn")
var obstacle_types := [barrel_scene, bin_scene, cardboardbox_scene, container_scene, crate_scene, foodstand_scene, garbagebag_scene, trafficcone_scene]
var obstacles : Array

#game variables
const PLAYER_START_POS := Vector2i(28, -102)
const CAM_START_POS := Vector2i(576, -329)
var difficulty 
const MAX_DIFFICULTY : int = 2
var score : int
const SCORE_MODIFIER : int = 10
var high_score : int
var speed : float
const START_SPEED : float = 10.0
const SPEED_MODIFIER : int = 5000
#MAX_SPEED was 25 before
const MAX_SPEED : int = 50
var screen_size : Vector2i
var ground_height : int
var game_running : bool
var last_obs 

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size
	ground_height = $ground.get_node("Sprite2D").texture.get_height()
	$GameOver.get_node("Button").pressed.connect(new_game)
	new_game()

func new_game():
	#reset the nodes
	score = 0
	show_score()
	game_running = false
	get_tree().paused = false
	difficulty = 0
	
	#delete all obstacles
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	#ground height: added for debugging purposes
	print(ground_height)
	
	#reset the nodes
	$player.position = PLAYER_START_POS
	$player.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$ground.position = Vector2i (0, 0)
	
	#reset HUD and Game Over Screen
	$HUD.get_node("GameStartLabel").show()
	$GameOver.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if game_running:
		#speed up and adjust difficulty
		
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()
			
		# generate obstacles
		generate_obs()

	#move player and camera	
		$player.position.x += speed
		$Camera2D.position.x += speed
		
		
		#update score
		score += speed
		show_score()
		
		#update ground position
		if $Camera2D.position.x - $ground.position.x > screen_size.x * 1.7:
			$ground.position.x += screen_size.x
			
		#update obstacles that are off screen:
		for obs in obstacles: 
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
	else: 
		if Input.is_action_just_pressed("ui_accept"):
			game_running = true
			$HUD.get_node("GameStartLabel").hide()

func generate_obs():
	#Generate ground obstacles -- randi_range was (300,500) before
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(5, 500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		#var obs
		var obs = obs_type.instantiate()
		var max_obs = difficulty + 1
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			#Obstacles Spawning from out of screen, ChatGPT suggest to using this instead of screen_size.x
			var obs_x : int = get_viewport_rect().size.x + score + 100 + (i * 100)
			#Note: 525 is hardcoded value for height
			var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) - 525
			last_obs = obs
			add_obs(obs, obs_x, obs_y)
			#print position of the obstacles - added for debugging purposes
			print(obs.position)

func add_obs(obs, x, y):
	obs.global_position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)

#Randomize the appearing obstacles ~From ChatGPT
#func generate_obstacle_group():
	#var obstacle_count = randi() % 3 + 1 #Generate between 1 and 3 obstacles
	#for i in range(obstacle_count):
		#generate_obs()

func remove_obs(obs): 
	obs.queue_free()
	obstacles.erase(obs)
	
func hit_obs(body):
	if body.name == "player":
		game_over()

func show_score():
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score / SCORE_MODIFIER)
	
func check_high_score():
	if score > high_score:
		high_score = score
		$HUD.get_node("HiScoreLabel").text = "HIGH SCORE:" + str(high_score / SCORE_MODIFIER)

func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY

#update if window size changed  ~~ this is from ChatGPT!
func _on_window_resized():
	screen_size = get_window().size

func game_over():
	check_high_score()
	get_tree().paused = true
	game_running = false 
	$GameOver.show()
