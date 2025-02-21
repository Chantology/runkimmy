class_name Chunk extends Node2D

@onready var end_trigger: Node2D = $EndPosition
@onready var static_body: StaticBody2D = $StaticBody2D
@export var collision_shapes: Array[CollisionShape2D]
var index: int

var pickups: Array[Pickup]


func _ready() -> void:
	for collision in collision_shapes:
		collision.disabled = true
	
	for pickup in $Pickups.get_children():
		pickups.append(pickup)


func get_width() -> float:
	return end_trigger.position.x


func on_draw() -> void:
	for pickup in pickups:
		pickup.setup_sprite()
		pickup.show()
