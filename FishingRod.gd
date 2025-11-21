extends Node2D

@export var player_path: NodePath
@onready var player = get_node(player_path)

@onready var rod_sprite: Sprite2D = $Rod

var shaking = false

var shake_amount = 0.2
var shake_speed = 20
var shake_timer = 0

func _draw():
	draw_circle(Vector2.ZERO, 4, Color.RED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var player_sprite: Sprite2D = player.get_node("Sprite2D")
	var is_facing_left = player_sprite.flip_h
	
	rod_sprite.flip_h = is_facing_left
	
	var flip_x_offset = rod_sprite.texture.get_width() * rod_sprite.scale.x + rod_sprite.offset.x
	position = Vector2((player.position.x - flip_x_offset) if is_facing_left else (player.position.x), player.position.y )

	if shaking:
		shake_timer += delta * shake_speed
		rod_sprite.rotation = sin(shake_timer) * shake_amount


func start_shaking():
	shaking = true
	shake_timer = 0
	
func stop_shaking():
	shaking = false
