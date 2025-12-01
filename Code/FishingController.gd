extends Node2D

var state = "uncast" # uncast, cast, reeling, bait_land, fish_biting, fish_on, fish_collect
var is_fishing
var holding_fish = false

var fishing_timer: Timer
var set_hook_timer: Timer
var fish_fight_timer: Timer

var fish_item = preload("res://Scenes/Fish.tscn")

var hold_progress = 0
var hold_total = 10
var fish_escape_time = 10
var fish_fights_left = 0
var fish_fight_interval = []
var fish_fight_duration = 3
var rod_cooldown = false
var rod_tension_time = 1

var is_holding = false
var target_fish = null
var held_fish = null

var skip_next_fishing_cycle = false

var auto_reel_after_cast = false

@onready var inventory = get_parent().get_node("Inventory")

@onready var fishing_ui: CanvasLayer = get_parent().get_node("FishingUI")
@onready var rod_cast_sound: AudioStreamPlayer2D = $RodCastSound
@onready var rod_reel_sound: AudioStreamPlayer2D = $RodReelSound
@onready var catch_fish_sound: AudioStreamPlayer2D = $CatchFishSound
@onready var fish_biting_sound: AudioStreamPlayer2D = $FishBitingSound
@onready var bgm_music: AudioStreamPlayer2D = $Music

@onready var bait: RigidBody2D = get_parent().get_node("Bait")


@onready var alert: Sprite2D = get_node("Alert")
@onready var rod_sprite: Sprite2D = get_parent().get_node("FishingRod/Rod")

@onready var fishing_line: Line2D = get_parent().get_node("FishingLine")
@onready var player: CharacterBody2D = get_parent().get_node("Player")

@onready var fish_sprite: Sprite2D = get_parent().get_node("FishSprite")
@onready var bait_scene: PackedScene

@onready var rod_tip: Node2D = get_parent().get_node("FishingRod/Rod/RodTip")
@onready var fishing_rod = get_parent().get_node("FishingRod")

@onready var star_particles = $StarParticles
@onready var water_splash = $WaterSplash
@onready var bait_splash = $BaitSplash




# --- Ready callback ---
func _ready():
	
	is_fishing = state != "uncast"
	alert.visible = false
	fishing_rod.visible = false
	fish_sprite.visible = false
	bait.visible = false
	
	bait.connect("bait_in_water", Callable(self, "_on_bait_in_water"))
	bait.connect("bait_landed", Callable(self, "_on_bait_landed"))
	var land_area = get_parent().get_node("LandArea")
	land_area.connect("body_entered", Callable(bait, "_on_LandArea_body_entered"))
	land_area.connect("body_exited", Callable(bait, "_on_LandArea_body_exited"))
	
	fish_sprite.connect("fish_collected", Callable(self, "_on_fish_collected"))
	
	bgm_music.play()
	


func emit_stars(position):
	star_particles.global_position = position
	star_particles.emitting = true


func do_not_reel_after_cast_lands():
	auto_reel_after_cast = false

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	is_fishing = state != "uncast"
	update_fishing_line()
	alert.position = Vector2(player.position.x, player.position.y - 100)
	#fish_sprite.position = Vector2(player.position.x, player.position.y -50)
	
	if state == "fish_on":
		if is_holding && rod_cooldown == false:
			hold_progress -= delta
			if (hold_progress <= 0):
				on_fish_fight_success()
				
			if false:
				if fish_fight_interval.size() > 0:
					
					# Past the time
					if fish_escape_time < fish_fight_interval[0] - fish_fight_duration:
						fish_fight_interval.remove_at(0)
						print("PAST THE TIME")
						
					# Before the time
					elif fish_escape_time > fish_fight_interval[0]:
						var lol = 3
						#print("before")

					# During the time
					else:
						rod_tension_time -= delta
						
						if rod_tension_time <= 0:
							start_rod_cooldown()
				
			
			
		fish_escape_time -= delta
	
	#elif state == "reeling":
	#	bait.move_towards_player(delta)
	
	# Splash effect
	if state == "fish_biting" || state == "fish_on":
		if randf() * 10 < 0.8:
			play_bait_splash()
	elif state == "reeling":
		if randf() * 10 < 0.4:
			play_bait_splash()

func start_rod_cooldown():
	rod_cooldown = true
	print("rod on cooldown!")
	await get_tree().create_timer(3.0).timeout
	rod_cooldown = false
	rod_tension_time = 1
	print("rod OFF COOLDOWN")

func cast_rod():
	fish_sprite.visible = false
	fishing_rod.visible = true
	state = "cast"
	auto_reel_after_cast = true
	
	bait.cast(rod_sprite.global_position, !rod_sprite.flip_h, 500, rod_sprite.global_position.y)

	rod_cast_sound.play()
	
	fishing_line.visible = true
	
	if held_fish != null:
		drop_held_fish()
	
func hack_drop_fish():
	held_fish = roll_fish()
	drop_held_fish()
	
	
func drop_held_fish():
	var dropped_fish = fish_item.instantiate()
	
	var fish_path = "res://Fish/" + held_fish + ".png"
	var fish_sprite = dropped_fish.get_node("Sprite2D")
	fish_sprite.texture = load(fish_path)
	
	dropped_fish.position = player.global_position + Vector2(0, -16)
	
	dropped_fish.add_to_group('fish')
	dropped_fish.set_freeze_enabled(false)
	dropped_fish.gravity_scale = 1
	dropped_fish.angular_damp = 10  # prevent wild spinning
	#dropped_fish.friction = 1
	#dropped_fish.bounce = 0.2
	
	dropped_fish.linear_velocity = Vector2(randf() * 100-50, -200)
	get_parent().add_child(dropped_fish)
	
	held_fish = null
	#var t = Timer.new()
	#t.one_shot = true
	#t.wait_time = 0.5  # adjust so it hits the ground
	#t.timeout.connect(Callable(self, "_on_fish_landed"), [dropped_fish])
	#add_child(t)
	#t.start()
	
func _on_fish_landed(fish):
	# Stop gravity but keep physics for player collisions
	#fish.mode = RigidBody2D.MODE_RIGID # behaves like movable object
	fish.gravity_scale = 0
	fish.linear_velocity = Vector2.ZERO
	fish.angular_velocity = 0
	fish.freeze = false  # can still move if bumped
	
func uncast_rod():
	fishing_rod.visible = false
	state = "uncast"
	bait.stop_bobbing()
	stop_reel_rod_sound()
	
	fishing_rod.stop_shaking()
	
	skip_next_fishing_cycle = true
	fishing_line.visible = false
	
	bait.visible = false


func collect_fish():
	state = "fish_collect"
	bait.stop_bobbing()
	stop_reel_rod_sound()
	skip_next_fishing_cycle = true
	bait.visible = false
	
	emit_stars(bait.global_position)
	
	inventory.catch_fish(target_fish)
	

func _on_fish_collected():
	fishing_rod.visible = false
	fishing_line.visible = false
	state = "uncast"

func reel_rod():
	if state != "bait_landed":
		return
	
	print("WINDING")
	fishing_rod.adjust_shaking(0.02, 15)
	bait.sleeping = false
	bait.bait_state = "reeling"
	state = "reeling"
	rod_reel_sound.play()
	
func stop_reel_rod():
	print("UNWINDING")
	bait.sleeping = true
	bait.bait_state = "in_water"
	fishing_rod.adjust_shaking(0.02, 5)
	state = "bait_landed"
	rod_reel_sound.stop()

	
func stop_wind_reel_during_cast():
	state = "bait_landed"
	print("stop winind")

func update_fishing_line():
	#var rod_tip_pos = Vector2(rod_sprite.global_position.x + (40 if !rod_sprite.flip_h else -40), rod_sprite.global_position.y-45)
	if fishing_rod.visible == true:
		if bait.visible:
			fishing_line.points = [rod_tip.global_position, bait.global_position]
		else:
			fishing_line.points = [rod_tip.global_position, fish_sprite.global_position]
	
func _on_bait_in_water():
	play_water_splash()
	start_fishing_cycle()
	
	if auto_reel_after_cast:
		reel_rod()
		auto_reel_after_cast = false
		
func hold_action_during_cast():
	auto_reel_after_cast = true
	
func _on_bait_landed():
	state = "bait_landed"
	fishing_rod.start_shaking(0.02, 5)
	
func play_water_splash():
	var splash = water_splash.duplicate()
	get_parent().add_child(splash)
	
	splash.global_position = bait.global_position
	splash.one_shot = true
	splash.emitting = true
	
	await get_tree().create_timer(splash.lifetime).timeout
	splash.queue_free()

func play_bait_splash():
	var splash = bait_splash.duplicate()
	get_parent().add_child(splash)
	
	splash.global_position = bait.global_position
	splash.one_shot = true
	splash.emitting = true
	
	await get_tree().create_timer(splash.lifetime).timeout
	splash.queue_free()

	
func start_fishing_cycle():
	if !(state == "bait_landed" || state == "reeling"):
		return
		
	print("Start fish cycle")
	while (state == "bait_landed" || state == "reeling" ) && bait.check_on_land() == false:
		skip_next_fishing_cycle = false
		await get_tree().create_timer(3.0).timeout
		
		if !(state == "bait_landed" || state == "reeling") || bait.check_on_land() || skip_next_fishing_cycle == true:
			return
			
		var roll = randf()
		print("Fishing roll: ", roll)
		
		if roll < 0.1:
			fish_biting()
			return
		
		
func fish_biting():
	print("FISH BITING!!!")
	alert.pop_animation()
	state = "fish_biting"
	
	set_hook_timer = Timer.new()
	set_hook_timer.one_shot = true
	set_hook_timer.wait_time = 5
	set_hook_timer.connect("timeout", Callable(self, "_on_set_hook_timeout"))
	add_child(set_hook_timer)
	set_hook_timer.start()
	
	bait.start_bobbing(5, 14)
	fishing_rod.start_shaking(0.1, 20)
	fish_biting_sound.play()

func set_hook():
	if state != "fish_biting":
		return		
	on_set_hook_success()	

func roll_fish():
	var fish_table = {
		"trash": 20,
		"seaweed": 20,
		"chest": 20,
		"goldfish": 20,
		"shrimp": 20,
		"sardine": 20,
		"clam": 15,
		"crab": 15,
		"octopus": 15,
		"eel": 15,
		"jellyfish": 15,
		"snapper": 12,
		"mackerel": 12,
		"salmon": 12,
		"swordfish": 5,
		"mahimahi": 5,
		"shark": 5
	}
	
	var total_chance = 0
	for value in fish_table.values():
		total_chance += value
	
	var roll = randf() * total_chance
	var sum = 0
	for fish in fish_table.keys():
		sum += fish_table[fish]
		if roll <= sum:
			return fish
	

func on_set_hook_success():
	print("HOOK SET BOIZ")
	alert.visible = false
	set_hook_timer.stop()
	state = "fish_on"
	
	fishing_rod.adjust_shaking(0.1, 20)
	fishing_ui.reel_UI.visible = true
	fishing_ui.fish_escape_bar.visible = true
	fishing_ui.fish_reel_bar.visible = true
	#fishing_ui.rod_tension_label.visible = true
	is_holding = false
	
	target_fish = roll_fish()
	if target_fish == "trash":
		fish_escape_time = 10
		hold_progress = 5
	elif target_fish == "seaweed":
		fish_escape_time = 9
		hold_progress = 5
	elif target_fish == "chest":
		fish_escape_time = 7
		hold_progress = 5
	elif target_fish == "goldfish":
		fish_escape_time = 15
		hold_progress = 6
		#fish_fight_interval = [8]
		#fish_fight_interval.push()
	elif target_fish == "shrimp":
		fish_escape_time = 13
		hold_progress = 6
	elif target_fish == "sardine":
		fish_escape_time = 10
		hold_progress = 7
	elif target_fish == "clam":
		fish_escape_time = 12
		hold_progress = 7
	elif target_fish == "crab":
		fish_escape_time = 15
		hold_progress = 10
	elif target_fish == "octopus":
		fish_escape_time = 13
		hold_progress = 10
	elif target_fish == "eel":
		fish_escape_time = 11
		hold_progress = 10
	elif target_fish == "jellyfish":
		fish_escape_time = 14
		hold_progress = 10
	elif target_fish == "snapper":
		fish_escape_time = 17
		hold_progress = 13
	elif target_fish == "salmon":
		fish_escape_time = 20
		hold_progress = 17	
	elif target_fish == "mackerel":
		fish_escape_time = 25
		hold_progress = 20
	elif target_fish == "swordfish":
		fish_escape_time = 27
		hold_progress = 25
	elif target_fish == "mahimahi":
		fish_escape_time = 35
		hold_progress = 30
	else: # shark
		fish_escape_time = 40
		hold_progress = 35

	#hold_progress = 0
		
	fishing_ui.set_fish_reel_bar_max(hold_progress)
	fishing_ui.set_fish_escape_bar_max(fish_escape_time)
		
	fish_fight_timer = Timer.new()
	fish_fight_timer.one_shot = true
	fish_fight_timer.wait_time = fish_escape_time
	fish_fight_timer.connect("timeout", Callable(self, "_on_fish_fight_timeout"))
	add_child(fish_fight_timer)

	fish_fight_timer.start()
	
func _on_set_hook_timeout():
	if state == "fish_biting":
		print("too slow rip")
		alert.visible = false
		state = "bait_landed"
		start_fishing_cycle()
		fishing_rod.stop_shaking()
		bait.start_bobbing(2, 5)
		fish_biting_sound.stop()

func on_fish_fight_success():
	print("U GOT DA FISH NIGGA")

	catch_fish_sound.play()
	fish_fight_timer.stop()
	fishing_rod.stop_shaking()
	
	collect_fish()
		#uncast_rod()
	
	fishing_ui.show_catch_text(target_fish)
	hold_fish_after_fishing(target_fish)
	fish_biting_sound.stop()
	
	fishing_ui.reel_UI.visible = false;
	fishing_ui.fish_escape_bar.visible = false
	fishing_ui.fish_reel_bar.visible = false
	fishing_ui.rod_tension_label.visible = false



func _on_fish_fight_timeout():
	print("Fish ran away")
	fishing_ui.reel_UI.visible = false
	fishing_ui.fish_escape_bar.visible = false
	fishing_ui.fish_reel_bar.visible = false
	fishing_rod.stop_shaking()
	fish_biting_sound.stop()
	uncast_rod()

func start_reel_rod_sound():
	rod_reel_sound.play()
	
func stop_reel_rod_sound():
	rod_reel_sound.stop()
	
func start_wind_reel_during_game():
	is_holding = true
	start_reel_rod_sound()
	fishing_rod.adjust_shaking(0.1, 45)
	
func stop_wind_reel_during_game():
	is_holding = false
	stop_reel_rod_sound()
	fishing_rod.adjust_shaking(0.1, 20)
	
func hold_fish_after_fishing(fish):
	
	held_fish = fish
	fish_sprite.texture = load("res://Fish/" + fish + ".png")
	
	fish_sprite.fly_fish_to_player(bait.global_position)
	#fish_sprite.visible = true
