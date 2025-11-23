extends Node2D

var state = "uncast" # uncast, cast, fish_biting, fish_on
var is_fishing
var holding_fish = false
var bait: RigidBody2D = null

var fishing_timer: Timer
var set_hook_timer: Timer
var fish_fight_timer: Timer

var hold_progress = 0
var fish_escape_time = 10
var is_holding = false

var skip_next_fishing_cycle = false


@onready var fishing_ui: CanvasLayer = get_parent().get_node("FishingUI")
@onready var rod_cast_sound: AudioStreamPlayer2D = $FishingSound
@onready var reel_rod_sound: AudioStreamPlayer2D = $ReelRodSound

@onready var alert: Sprite2D = get_node("Alert")
@onready var rod_sprite: Sprite2D = get_parent().get_node("FishingRod/Rod")

@onready var fishing_line: Line2D = get_parent().get_node("FishingLine")
@onready var player: CharacterBody2D = get_parent().get_node("Player")

@onready var fish_sprite: Sprite2D = get_parent().get_node("FishSprite")
@onready var bait_scene: PackedScene

@onready var rod_tip: Node2D = get_parent().get_node("FishingRod/Rod/RodTip")
@onready var fishing_rod = get_parent().get_node("FishingRod")




# --- Ready callback ---
func _ready():
	is_fishing = state != "uncast"
	alert.visible = false
	fishing_rod.visible = false
	fish_sprite.visible = false

	set_hook_timer = Timer.new()
	set_hook_timer.one_shot = true
	set_hook_timer.wait_time = 5
	set_hook_timer.connect("timeout", Callable(self, "_on_set_hook_timeout"))
	add_child(set_hook_timer)
	
	fish_fight_timer = Timer.new()
	fish_fight_timer.one_shot = true
	fish_fight_timer.wait_time = 10.0
	fish_fight_timer.connect("timeout", Callable(self, "_on_fish_fight_timeout"))
	add_child(fish_fight_timer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	is_fishing = state != "uncast"
	update_fishing_line()
	alert.position = Vector2(player.position.x, player.position.y - 100)
	fish_sprite.position = Vector2(player.position.x, player.position.y - 75)
	
	if state == "fish_on":
		if is_holding:
			hold_progress -= delta
			
			if (hold_progress <= 0):
				on_fish_fight_success()
			
		fish_escape_time -= delta
	

func cast_rod():
	fish_sprite.visible = false
	fishing_rod.visible = true
	state = "cast"
	
	var bait_scene = load("res://Bait.tscn")
	bait = bait_scene.instantiate()
	get_parent().add_child(bait)	
	bait.connect("bait_in_water", Callable(self, "_on_bait_in_water"))
	
	var land_area = get_parent().get_node("LandArea")
	land_area.connect("body_entered", Callable(bait, "_on_LandArea_body_entered"))
	land_area.connect("body_exited", Callable(bait, "_on_LandArea_body_exited"))
	
	
	bait.cast(rod_sprite.global_position, !rod_sprite.flip_h, 500, rod_sprite.global_position.y)
	rod_cast_sound.play()
	
	fishing_line.visible = true
	
func reel_rod():
	fishing_rod.visible = false
	state = "uncast"
	bait.stop_bobbing()
	stop_reel_rod_sound()
	
	skip_next_fishing_cycle = true
	fishing_line.visible = false
	
	if bait:
		bait.queue_free()
		bait = null
	

func update_fishing_line():
	#var rod_tip_pos = Vector2(rod_sprite.global_position.x + (40 if !rod_sprite.flip_h else -40), rod_sprite.global_position.y-45)
	if bait:
		fishing_line.points = [rod_tip.global_position, bait.global_position]
	
	
func _on_bait_in_water():
	print("bait landed in water du maa")
	start_fishing_cycle()
	
func start_fishing_cycle():
	if state != "cast":
		return
	
	while state == "cast":
		print("Start fish cycle")
		skip_next_fishing_cycle = false
		await get_tree().create_timer(3.0).timeout
		
		if state != "cast" || skip_next_fishing_cycle == true:
			return
			
		var roll = randf()
		print("Fishing roll: ", roll)
		
		if roll < 1:
			print("FISH BITING!!!")
			alert.pop_animation()
			state = "fish_biting"
			set_hook_timer.start()
			bait.start_bobbing()
			fishing_rod.start_shaking()
			
			return
		else:
			print("nothing yet .. wait again")
		

func set_hook():
	if state != "fish_biting":
		return
	print("HOOK SET BOIZ")
	alert.visible = false
	set_hook_timer.stop()
	state = "fish_on"
	fish_escape_time = 10
	
	fishing_ui.fish_timer_label.visible = true
	fishing_ui.fish_escape_label.visible = true
	fishing_ui.fish_reel_label.visible = true
		
		
		OK SORT OUT AND RENAME FISH ESCAPE TIMER AND FISH FIGHT TIME PROPERLY
		
		
	on_set_hook_success()	
	
func on_set_hook_success():
	print("mini game start")
	state = "fish_on"
	fishing_rod.adjust_shaking(0.1, 20)
	
	fishing_ui.reel_UI.visible = true
	fishing_ui.fish_escape_bar.visible = true
	fishing_ui.fish_reel_bar.visible = true
	hold_progress = 5
	is_holding = false
	
	fish_fight_timer.start()
	
func _on_set_hook_timeout():
	if state == "fish_biting":
		print("too slow rip")
		alert.visible = false
		state = "cast"
		start_fishing_cycle()
		fishing_rod.stop_shaking()
		bait.stop_bobbing()

func on_fish_fight_success():
	print("U GOT DA FISH NIGGA")
	fish_fight_timer.stop()
	reel_rod()
	fishing_rod.stop_shaking()
	fish_sprite.visible = true
	fishing_ui.reel_UI.visible = false;
	fishing_ui.fish_escape_bar.visible = false
	fishing_ui.fish_reel_bar.visible = false

func _on_fish_fight_timeout():
	print("Fish ran away")
	fishing_ui.reel_UI.visible = false
	fishing_ui.fish_escape_bar.visible = false
	fishing_ui.fish_reel_bar.visible = false
	fishing_rod.stop_shaking()
	reel_rod()

func start_reel_rod_sound():
	reel_rod_sound.play()
	
func stop_reel_rod_sound():
	reel_rod_sound.stop()
	
func start_wind_reel_during_game():
	is_holding = true
	start_reel_rod_sound()
	fishing_rod.adjust_shaking(0.1, 32)
	
func stop_wind_reel_during_game():
	is_holding = false
	stop_reel_rod_sound()
	fishing_rod.adjust_shaking(0.1, 20)
