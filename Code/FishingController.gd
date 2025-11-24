extends Node2D

var state = "uncast" # uncast, cast, reeling, fish_biting, fish_on
var is_fishing
var holding_fish = false

var fishing_timer: Timer
var set_hook_timer: Timer
var fish_fight_timer: Timer

var hold_progress = 0
var fish_escape_time = 10
var is_holding = false
var target_fish = null

var skip_next_fishing_cycle = false


@onready var fishing_ui: CanvasLayer = get_parent().get_node("FishingUI")
@onready var rod_cast_sound: AudioStreamPlayer2D = $RodCastSound
@onready var rod_reel_sound: AudioStreamPlayer2D = $RodReelSound
@onready var catch_fish_sound: AudioStreamPlayer2D = $CatchFishSound
@onready var fish_biting_sound: AudioStreamPlayer2D = $FishBitingSound

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
	var land_area = get_parent().get_node("LandArea")
	land_area.connect("body_entered", Callable(bait, "_on_LandArea_body_entered"))
	land_area.connect("body_exited", Callable(bait, "_on_LandArea_body_exited"))
	

func emit_stars(position):
	star_particles.global_position = position
	star_particles.emitting = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	is_fishing = state != "uncast"
	update_fishing_line()
	alert.position = Vector2(player.position.x, player.position.y - 100)
	fish_sprite.position = Vector2(player.position.x, player.position.y -50)
	
	if state == "fish_on":
		if is_holding:
			hold_progress -= delta
			
			if (hold_progress <= 0):
				on_fish_fight_success()
			
		fish_escape_time -= delta
	
	#elif state == "cast":
		#bait.move_towards_player(delta)
	
	# Splash effect
	if state == "fish_biting" || state == "fish_on":
		if randf() * 10 < 0.8:
			play_bait_splash()

func stop_wind_reel_during_cast():
	state = "cast"
	print("stop winind")
	

func cast_rod():
	fish_sprite.visible = false
	fishing_rod.visible = true
	state = "cast"
	
	bait.cast(rod_sprite.global_position, !rod_sprite.flip_h, 500, rod_sprite.global_position.y)

	rod_cast_sound.play()
	
	fishing_line.visible = true
	
func uncast_rod():
	fishing_rod.visible = false
	state = "uncast"
	bait.stop_bobbing()
	stop_reel_rod_sound()
	
	skip_next_fishing_cycle = true
	fishing_line.visible = false
	
	bait.visible = false

func reel_rod():
	print('player global: ' + str(player.global_position) + "    local: " + str(player.position))
	print('bait   global: ' + str(bait.global_position) + "    local: " + str(bait.position))
	
	print("WINDING")
	state = "reeling"
	

func update_fishing_line():
	#var rod_tip_pos = Vector2(rod_sprite.global_position.x + (40 if !rod_sprite.flip_h else -40), rod_sprite.global_position.y-45)
	if bait.visible:
		fishing_line.points = [rod_tip.global_position, bait.global_position]
	
	
func _on_bait_in_water():
	play_water_splash()
	start_fishing_cycle()
	
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
	if state != "cast":
		return
		
	print("Start fish cycle")
	while state == "cast":
		skip_next_fishing_cycle = false
		await get_tree().create_timer(3.0).timeout
		
		if state != "cast" || skip_next_fishing_cycle == true:
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
	fishing_rod.start_shaking()
	fish_biting_sound.play()

func set_hook():
	if state != "fish_biting":
		return		
	on_set_hook_success()	

func roll_fish():
	var fish_table = {
		"goldfish": 30,
		"shrimp": 25,
		"sardine": 25,
		#"snapper": 8,
		#"salmon": 6,
		#"mackerel": 6
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
	is_holding = false
	
	target_fish = roll_fish()
	if target_fish == "goldfish":
		fish_escape_time = 10
		hold_progress = 5
	elif target_fish == "shrimp":
		fish_escape_time = 8
		hold_progress = 5
	else:
		fish_escape_time = 6
		hold_progress = 5
		
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
		state = "cast"
		start_fishing_cycle()
		fishing_rod.stop_shaking()
		bait.start_bobbing(2, 5)
		fish_biting_sound.stop()

func on_fish_fight_success():
	print("U GOT DA FISH NIGGA")
	
	emit_stars(player.global_position + Vector2(0, -50))
	
	catch_fish_sound.play()
	fish_fight_timer.stop()
	uncast_rod()
	fishing_rod.stop_shaking()
	hold_fish_after_fishing(target_fish)
	fish_biting_sound.stop()
	
	fishing_ui.reel_UI.visible = false;
	fishing_ui.fish_escape_bar.visible = false
	fishing_ui.fish_reel_bar.visible = false



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
	fishing_rod.adjust_shaking(0.1, 32)
	
func stop_wind_reel_during_game():
	is_holding = false
	stop_reel_rod_sound()
	fishing_rod.adjust_shaking(0.1, 20)
	
func hold_fish_after_fishing(fish):
	
	fish_sprite.texture = load("res://Fish/" + fish + ".png")
	
	fish_sprite.visible = true
