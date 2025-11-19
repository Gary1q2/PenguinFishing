extends CharacterBody2D

# --- Constants ---
const MOVE_SPEED = 300

# --- State variables ---
var input: Vector2
var state = "idle"
var is_fishing = false
var holding_fish = false

# --- Node references ---

@onready var sprite: Sprite2D = $Sprite2D

@onready var fish_sprite: Sprite2D = $FishSprite
@onready var bait_scene: PackedScene

@onready var fishing_rod = get_parent().get_node("FishingRod")


# --- Ready callback ---
func _ready():
	fishing_rod.visible = false
	#fish_sprite.visible = false

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
		if !is_fishing:
			fishing_rod.visible = true
			fishing_rod.cast_rod()
			is_fishing = true
		else:
			fishing_rod.visible = false
			fishing_rod.reel_rod()
			is_fishing = false
			

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
