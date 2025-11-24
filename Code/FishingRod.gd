extends Node2D

@export var player_path: NodePath
@onready var player = get_node(player_path)

@onready var rod_sprite: Sprite2D = $Rod
@onready var rod_tip: Node2D = $Rod/RodTip

var shaking = false

var shake_amount = 0.05
var shake_speed = 20
var shake_timer = 0

var rod_tip_init_pos;

func _ready():
	rod_tip_init_pos = rod_tip.position

#func _draw():
	#draw_circle(global_position, 4, Color.RED)
	#draw_circle(rod_sprite.global_position, 5, Color.PURPLE)
	#draw_circle(rod_tip.global_position, 4, Color.GREEN)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var player_sprite: Sprite2D = player.get_node("Sprite2D")
	var is_facing_left = player_sprite.flip_h
	
	rod_sprite.flip_h = is_facing_left
	
	var flip_x_offset = 20 # rod_sprite.texture.get_width() * rod_sprite.scale.x + rod_sprite.offset.x
	position = Vector2((player.position.x - flip_x_offset) if is_facing_left else (player.position.x + flip_x_offset), player.position.y)
	rod_sprite.offset.x = -130 if is_facing_left else -15
	
	
	rod_tip.position = Vector2(-rod_tip_init_pos.x if is_facing_left else rod_tip_init_pos.x, rod_tip_init_pos.y)

	if shaking:
		shake_timer += delta * shake_speed
		rod_sprite.rotation = sin(shake_timer) * shake_amount

func start_shaking():
	shaking = true
	shake_timer = 0
	
func stop_shaking():
	rod_sprite.rotation = 0
	shaking = false
	
func adjust_shaking(new_amount, new_speed):
	shake_amount = new_amount
	shake_speed = new_speed
