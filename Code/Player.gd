extends CharacterBody2D

const MOVE_SPEED = 300

var input: Vector2

@export var fishing_con_path: NodePath

@onready var sprite: Sprite2D = $Sprite2D
@onready var fishing_con = get_node(fishing_con_path)
@onready var animation = $Sprite2D/AnimationPlayer

func _ready():
	animation.play("idle")
	$PushArea.body_entered.connect(Callable(self, "_on_fish_pushed"))

func _on_fish_pushed(body):
	if body.is_in_group("fish") and body is RigidBody2D:
		var push_dir = (body.global_position - global_position).normalized()
		body.apply_central_impulse(push_dir * 200)  # tweak force as needed

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
			fishing_con.hold_action_during_cast()
		elif fishing_con.state == "bait_landed": #&& fishing_con.bait.check_on_land() == false:
			fishing_con.reel_rod()
		elif fishing_con.state == "fish_biting":
			fishing_con.set_hook()
			fishing_con.start_wind_reel_during_game()
		elif fishing_con.state == "fish_on":
			fishing_con.start_wind_reel_during_game()
	
	if Input.is_action_just_released("action"):
		if (fishing_con.state == "fish_on"):
			fishing_con.stop_wind_reel_during_game()
		elif fishing_con.state == "reeling":
			fishing_con.stop_reel_rod()
		elif fishing_con.state == "cast":
			fishing_con.do_not_reel_after_cast_lands()
			
	#if Input.is_key_pressed(KEY_1):
	#	if fishing_con.state == "bait_landed":
	#		print('hacked a fish')
	#		fishing_con.fish_biting()
	#if Input.is_key_pressed(KEY_2):

			
	#if Input.is_action_just_pressed("hack"):
	#	fishing_con.hack_drop_fish()
	#	var scene = get_tree().current_scene
	#	get_tree().change_scene_to_file(scene.filename)
		


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
