extends Node

var sprites_folder_path: String = "res://assets/sprites/pickups/"
var sprites_array: Array = []
var supported_sprite_files: Array = [".png"]


func _ready() -> void:
	load_sprites_array()


func load_sprites_array() -> void:
	var directory: DirAccess = DirAccess.open(sprites_folder_path)
	if directory:
		directory.list_dir_begin()
		var file_name = directory.get_next()
		
		while file_name != "":
			if directory.current_is_dir():
				pass # If you want recursive file loading, do it here. I think
			else:    # it's a bit overkill :)
				for file_type in supported_sprite_files:
					#print(file_name)
					if file_name.contains(file_type):
						if OS.has_feature("editor"):
							if file_name.contains(".import"):
								continue
						else:
							if file_name.ends_with(".import"):
								file_name = file_name.trim_suffix(".import")
						
						var sprite_file_path: String = sprites_folder_path + "/" + file_name
						var new_sprite = load(sprite_file_path)
						sprites_array.append(new_sprite)
			
			file_name = directory.get_next()
	else:
		print("An error occurred when trying to access the sounds path: " + sprites_folder_path)


func get_random_sprite() -> Texture2D:
	return sprites_array.pick_random()
