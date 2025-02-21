extends Node

# SAVE / LOAD
const SAVE_FILE = "user://highscore.save"
const CONFIG_SECTION = "game"
const HIGH_SCORE_KEY = "high_score"

# UPDATE
var distance_score: float = 0.0
var additional_score: float = 0.0 # score we get from collectibles and stuff
var high_score: float = 0.0
var score_speed: float = 3.0

func _ready() -> void:
	load_high_score()


func load_high_score() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_FILE)
	
	if err == OK:
		high_score = config.get_value(CONFIG_SECTION, HIGH_SCORE_KEY, 0.0)
	else:
		high_score = 0.0


func save_high_score() -> void:
	var config = ConfigFile.new()
	config.set_value(CONFIG_SECTION, HIGH_SCORE_KEY, high_score)
	config.save(SAVE_FILE)


func get_score_as_string() -> String:
	return str(int(distance_score + additional_score))
