extends Node

"""
How it works:
First we (automatically) load all the sounds placed inside res://assets/audio/sounds/   and	place them inside the sounds_dictionary, 
using the sound name as the dictionary key.

Then, from anywhere in the game, we can call Audio.play_sound(sound_name) and it
will play :)
"""


var sound_folder_path: String = "res://assets/audio/sounds/"
var sounds_dictionary: Dictionary = {}

var supported_audio_files: Array = [".wav", ".ogg", ".mp3"]

var music_tracks: Dictionary = {
	"menu": load("res://assets/audio/music/Juhani Junkala [Retro Game Music Pack] Title Screen.mp3"),
	"game": load("res://assets/audio/music/Juhani Junkala [Retro Game Music Pack] Level 1.mp3")
}

@onready var music_player: AudioStreamPlayer = $MusicPlayer


func _ready() -> void:
	load_sound_paths_dictionary()


func play_sound(sound_name: String, pitch_scale: float = -1) -> void:
	if !sounds_dictionary.has(sound_name):
		print("Sound not present in sounds dictionary: " + sound_name)
		return
	
	var sound_stream: AudioStream = sounds_dictionary[sound_name]
	
	if sound_stream:
		var stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
		stream_player.stream = sound_stream
		stream_player.bus = "sound"
		
		stream_player.finished.connect(stream_player.queue_free)
		
		randomize()
		if pitch_scale == -1:
			pitch_scale = randf_range(0.975, 1.025)
		
		stream_player.pitch_scale = pitch_scale # Randomize pitch so it's not always the same!
		
		add_child(stream_player)
		
		stream_player.play()


func load_sound_paths_dictionary() -> void:
	var directory: DirAccess = DirAccess.open(sound_folder_path)
	if directory:
		directory.list_dir_begin()
		var file_name = directory.get_next()
		
		while file_name != "":
			if directory.current_is_dir():
				pass # If you want recursive file loading, do it here. I think
			else:    # it's a bit overkill :)
				for file_type in supported_audio_files:
					#print(file_name)
					if file_name.contains(file_type):
						if OS.has_feature("editor"):
							if file_name.contains(".import"):
								continue
						else:
							if file_name.ends_with(".import"):
								file_name = file_name.trim_suffix(".import")
						
						var sound_file_path: String = sound_folder_path + "/" + file_name
						var new_audio_stream = load(sound_file_path)
						if new_audio_stream is AudioStream:
							sounds_dictionary[file_name.trim_suffix(file_type)] = new_audio_stream
						# print("Successfully loaded sound: " + sound_file_path)
			
			file_name = directory.get_next()
	else:
		print("An error occurred when trying to access the sounds path: " + sound_folder_path)


func play_music(track: String) -> void:
	music_player.stream = music_tracks[track]
	music_player.play()
