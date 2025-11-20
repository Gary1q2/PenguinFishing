extends CharacterBody2D

const MOVE_SPEED = 300

var input: Vector2

@export var fishing_con_path: NodePath

@onready var sprite: Sprite2D = $Sprite2D
@onready var fishing_con = get_node(fishing_con_path)

# --- Input handling ---
func get_input() -> Vector2:
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	return input.normalized()

# --- Physics update ---
func _physics_process(delta):
	var dir = get_input()
	
	# Movement
	velocity = dir * MOVE_SPEED
	move_and_slide()

	# Sprite and rod flipping
	if velocity.x > 0:
		sprite.flip_h = false
	elif velocity.x < 0:
		sprite.flip_h = true

	# Start fishing input
	if Input.is_action_just_pressed("action"):
		if !fishing_con.is_fishing:
			fishing_con.cast_rod()
		else:
			fishing_con.reel_rod()

#func show_fish():
#	holding_fish = true
#	fish_sprite.visible = true
#	print("Caught fish!")
#
	# Stop fishing state
#	is_fishing = false

	# Make the fish stay for 1 second
#	var t := get_tree().create_timer(2.0)
#	await t.timeout

#	fish_sprite.visible = false
#	holding_fish = false
