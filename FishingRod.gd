extends Node2D

@export var player_path: NodePath
@onready var player = get_node(player_path)

@onready var rod_sprite: Sprite2D = $Rod

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var player_sprite: Sprite2D = player.get_node("Sprite2D")
	var is_facing_left = player_sprite.flip_h
	
	rod_sprite.flip_h = is_facing_left
	
	position = Vector2((player.position.x - 55) if is_facing_left else (player.position.x + 55), player.position.y )
