extends Node2D

@export var player_path: NodePath
@onready var player = get_node(player_path)

@onready var rod_sprite: Sprite2D = $Rod
@onready var fishing_line: Line2D = get_parent().get_node("FishingLine")
@onready var rod_cast_sound: AudioStreamPlayer2D = $FishingSound

var bait: RigidBody2D = null;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var player_sprite: Sprite2D = player.get_node("Sprite2D")
	var is_facing_left = player_sprite.flip_h
	
	rod_sprite.flip_h = is_facing_left
	
	position = Vector2((player.position.x - 55) if is_facing_left else (player.position.x + 55), player.position.y )
	
	update_fishing_line()




func update_fishing_line():
	var rod_tip_pos = Vector2(self.position.x + (40 if !rod_sprite.flip_h else -40), self.position.y-45)
	
	if bait:
		fishing_line.points = [rod_tip_pos, bait.global_position]
	
func cast_rod():	
	var bait_scene = load("res://Bait.tscn")
	bait = bait_scene.instantiate()
	get_parent().add_child(bait)
	
	var land_area = get_parent().get_node("LandArea")
	land_area.connect("body_entered", Callable(bait, "_on_LandArea_body_entered"))
	land_area.connect("body_exited", Callable(bait, "_on_LandArea_body_exited"))
	
	bait.cast(self.global_position, !rod_sprite.flip_h, 500, self.position.y)
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
	#is_fishing = false
	fishing_line.visible = false
	
	if bait:
		bait.queue_free()
		bait = null
