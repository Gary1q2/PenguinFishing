extends Node2D

var state = "idle";
var is_fishing = false;
var holding_fish = false;
var bait: RigidBody2D = null;

var fishing_timer: Timer;

@onready var rod_cast_sound: AudioStreamPlayer2D = $FishingSound

@onready var rod_sprite: Sprite2D = get_parent().get_node("FishingRod/Rod")

@onready var fishing_line: Line2D = get_parent().get_node("FishingLine")

@onready var fish_sprite: Sprite2D = $FishSprite
@onready var bait_scene: PackedScene

@onready var fishing_rod = get_parent().get_node("FishingRod")



# --- Ready callback ---
func _ready():
	fishing_rod.visible = false
	#fish_sprite.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_fishing_line()


	

func cast_rod():
	fishing_rod.visible = true
	is_fishing = true
	
	var bait_scene = load("res://Bait.tscn")
	bait = bait_scene.instantiate()
	get_parent().add_child(bait)	
	bait.connect("bait_in_water", Callable(self, "_on_bait_in_water"))
	
	var land_area = get_parent().get_node("LandArea")
	land_area.connect("body_entered", Callable(bait, "_on_LandArea_body_entered"))
	land_area.connect("body_exited", Callable(bait, "_on_LandArea_body_exited"))
	
	
	bait.cast(rod_sprite.global_position, !rod_sprite.flip_h, 500, rod_sprite.global_position.y)
	rod_cast_sound.play()
	
	#is_fishing = true
	fishing_line.visible = true
	

	if false:
		
		
		# Random wait between 3 and 10 seconds
		var wait_time = randf_range(3.0, 10.0)
		print("Waiting for fish: ", wait_time)

		var timer := get_tree().create_timer(wait_time)
		await timer.timeout

		# If player moved or cancelled before timer finished
		#if not is_fishing:
		#	print("Fishing cancelled")
		#	return

		# Fish caught
		#show_fish()
	
func reel_rod():
	fishing_rod.visible = false
	is_fishing = false	
	
	fishing_line.visible = false
	
	if bait:
		bait.queue_free()
		bait = null
	

func update_fishing_line():
	var rod_tip_pos = Vector2(rod_sprite.global_position.x + (40 if !rod_sprite.flip_h else -40), rod_sprite.global_position.y-45)
	
	if bait:
		fishing_line.points = [rod_tip_pos, bait.global_position]
	
	
func _on_bait_in_water():
	print("bait landed in water du maa")
	start_fishing_cycle()
	
func start_fishing_cycle():
	if !is_fishing:
		return
	
	while is_fishing:
		await get_tree().create_timer(3.0).timeout
		
		if !is_fishing:
			print("fishing stopped")
			return
			
		var roll = randf()
		print("fishing roll: ", roll)
		
		if roll < 0.5:
			print("FISHONNNN")
			return
		else:
			print("nothing yet .. wait again")
		
	
