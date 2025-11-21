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
		if fishing_con.state == "uncast":
			fishing_con.cast_rod()
		elif fishing_con.state == "cast":
			fishing_con.reel_rod()
		elif fishing_con.state == "fish_biting":
			fishing_con.set_hook()
		elif fishing_con.state == "fish_on":
			print("HOLDING E to REEL FISH")
			fishing_con.is_holding = true
			fishing_con.start_reel_rod_sound()
	
	if Input.is_action_just_released("action"):
		if (fishing_con.state == "fish_on"):
			print("RELEASED E not reeling now")
			fishing_con.is_holding = false
			fishing_con.stop_reel_rod_sound()

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
