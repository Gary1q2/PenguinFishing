extends RigidBody2D

signal bait_in_water


@export var bait_sprite_path: NodePath

var target_y: float
var facing_right: bool

var bait_state = "uncast"
var off_land = false

var land_y = 0

var bob_amplitude = 5       # pixels up/down
var bob_speed = 2.0         # speed of bobbing
var bob_time = 0.0

@onready var bait_splash = $BaitSplash
@onready var bait_sprite = get_node(bait_sprite_path)

# Call this when casting
func cast(start_position: Vector2, facing_right: bool, speed: float, player_y: float):
	#bait_sprite.texture = load("res://float.png")
	
	
	var offset = 0
	position = start_position + Vector2(offset if facing_right else -offset, -40)
	sleeping = false
	rotation = 0
	bait_state = "cast"
	off_land = false

	# Forward + upward direction
	var dir = Vector2(1, -0.5) if facing_right else Vector2(-1, -0.5)
	linear_velocity = dir.normalized() * speed

	angular_velocity = 8 * (1 if facing_right else -1)

	# Store the target Y for landing
	self.target_y = player_y + 60
	self.facing_right = facing_right

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# Stop when it reaches the target Y
	if position.y >= target_y and bait_state == "cast":
		
		if off_land:
			bait_state = "in_water"
			linear_velocity = Vector2.ZERO
			
			sleeping = true
			bait_splash.play()
			gravity_scale = 0
			emit_signal("bait_in_water")
			start_bob_once(10)
			
		else:
			bait_state = "rolling"
			linear_velocity.y = 0
			gravity_scale = 0
			
			angular_velocity = 25 * (1 if facing_right else -1)

func start_bob_once(bob_amount):
	var duration = 0.25
	
	var tween = create_tween()
	tween.tween_property(self, "position:y", bob_amount, duration / 2).as_relative()
	tween.tween_property(self, "position:y", -bob_amount, duration / 2).as_relative()

#func _on_LandArea_body_entered(body):
#	if body == self:
#		print("bait hit land")

func _on_LandArea_body_exited(body):
	if body == self:
		off_land = true	
		if bait_state == "rolling":
			linear_velocity = Vector2.ZERO	
			sleeping = true
			bait_splash.play()
			gravity_scale = 0
			emit_signal("bait_in_water")
			start_bob_once(2)
