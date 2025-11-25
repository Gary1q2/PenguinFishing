extends RigidBody2D

signal bait_in_water
signal bait_landed


@export var bait_sprite_path: NodePath

var target_y: float
var facing_right: bool

var bait_state = "uncast"
var off_land = false
var landed = false

#var land_pos = null

var bob_amplitude = 5       # pixels up/down
var bob_speed = 2.0         # speed of bobbing
var bob_time = 0.0

@onready var bait_splash = $BaitSplash
@onready var bait_sprite = get_node("BobGroup/BaitSprite")
@onready var bob_group = get_node("BobGroup")
@onready var land_detector = $BaitArea

@onready var player = get_parent().get_node("Player")
@onready var fishing_con = get_parent().get_node("FishingController")



func _ready():
	sleeping = true
	gravity_scale = 0
	print(bob_group.position)

func _process(delta):
	if bait_state == "in_water" || (bait_state == "reeling" && check_on_land() == false):
		bob_time += delta * bob_speed
		bob_group.global_position.y = global_position.y + sin(bob_time) * bob_amplitude

# Call this when casting
func cast(start_position: Vector2, facing_right: bool, speed: float, player_y: float):
	visible = true
	
	var offset = 0
	position = start_position + Vector2(offset if facing_right else -offset, -40)
	sleeping = false
	rotation = 0
	gravity_scale = 1
	bait_state = "cast"
	off_land = false
	landed = false

	# Forward + upward direction
	var dir = Vector2(1, -0.5) if facing_right else Vector2(-1, -0.5)
	linear_velocity = dir.normalized() * speed

	angular_velocity = 8 * (1 if facing_right else -1)

	# Store the target Y for landing
	self.target_y = player_y + 60
	self.facing_right = facing_right
		
func check_on_land():
	var is_on_land = false
	for area in land_detector.get_overlapping_areas():
		if area.name == "LandArea":
			return true
	return false

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# Stop when it reaches the target Y
	if bait_state == "cast":
		if landed == false && position.y >= target_y:
			print("landed somewhere")
			landed = true
			emit_signal("bait_landed")
			if check_on_land():
				bait_state = "rolling"
				linear_velocity.y = 0
				gravity_scale = 0
				print("on land")
				angular_velocity = 25 * (1 if facing_right else -1)
			else:
				bait_enter_water()
				print("on water")
		#elif landed == true:
			

	elif bait_state == "rolling" && !check_on_land():
		bait_enter_water()
		
	elif bait_state == "reeling":
		var dir = player.global_position - global_position
		var distance = dir.length()
		var on_land = check_on_land()	

		var speed = 150
		print(distance)
		#if distance > 100:
		linear_velocity = dir.normalized() * speed
			
			#if on_land:
			#	if player.global_position.x < global_position.x:
			#		angular_velocity = -4
			#	else:
			#		angular_velocity = 4
		#else:
		#	linear_velocity = Vector2.ZERO
		#	print("reached player")
		if distance < 75 || check_on_land():
			visible = false
			print("bai")
			fishing_con.uncast_rod()
			bait_state = "uncast"
		
func bait_enter_water():
	bait_state = "in_water"
	linear_velocity = Vector2.ZERO
	
	sleeping = true
	bait_splash.play()
	gravity_scale = 0
	#land_pos = bob_group.global_position
	emit_signal("bait_in_water")

	var tween = start_bob_once(10)
	await tween.finished
	start_bobbing(2, 5)

func start_bob_once(bob_amount):
	var duration = 0.25
	
	var tween = create_tween()
	tween.tween_property(self, "position:y", bob_amount, duration / 2).as_relative()
	tween.tween_property(self, "position:y", -bob_amount, duration / 2).as_relative()
	
	return tween

func start_bobbing(amplitude, speed):
	bob_time = 0
	bob_amplitude = amplitude
	bob_speed = speed
	
func stop_bobbing():
	bait_state = "in_water"
	bob_group.position.y = 0
	
	

#func _on_LandArea_body_entered(body):
#	if body == self:
#		print("bait hit land")

#func _on_LandArea_body_exited(body):
#	if body == self:
#		off_land = true	
