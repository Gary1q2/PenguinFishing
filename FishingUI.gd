extends CanvasLayer

@onready var  fishing_con = get_parent().get_node("FishingController")

@onready var fish_timer_label: Label = $FishFightTimer
@onready var fish_escape_label: Label = $FishEscapeTimer
@onready var reel_UI: Sprite2D = $ReelUI

@onready var fish_escape_bar: ProgressBar = $FishEscapeBar
@onready var fish_reel_bar: ProgressBar = $FishReelBar
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fish_timer_label.text = "lala"
	fish_timer_label.visible = false
	fish_timer_label.global_position = Vector2(600, 500)
	
	reel_UI.visible = false
	

	fish_escape_label.text = "lala"
	fish_escape_label.visible = false
	fish_escape_label.global_position = Vector2(700, 500)
	
	fish_escape_bar.visible = false
	fish_escape_bar.min_value = 0
	fish_escape_bar.max_value = fishing_con.fish_escape_time
	fish_escape_bar.value = 10
	fish_escape_bar.global_position = Vector2(700, 500)
	#fish_escape_bar.rect_size = Vector2(300, 300)

	fish_reel_bar.visible = false
	fish_reel_bar.min_value = 0
	fish_reel_bar.max_value = 5
	fish_reel_bar.value = 0
	fish_reel_bar.global_position = Vector2(700, 550)
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	if fishing_con.is_holding:
		reel_UI.rotation -= delta * 10

	fish_timer_label.text = "%.2f" % fishing_con.hold_progress
	fish_escape_label.text = "%.2f" % fishing_con.fish_escape_time
	
	fish_escape_bar.value = fishing_con.fish_escape_time
	
	var bar_percent = fish_escape_bar.value / fish_escape_bar.max_value
	if bar_percent > 0.7:
		fish_escape_bar.modulate = Color(0.2, 1.0, 0.2)
	elif bar_percent > 0.4:
		fish_escape_bar.modulate = Color(1, 1, 0.2)
	elif bar_percent > 0.2:
		fish_escape_bar.modulate = Color(1, 0.5, 0)
	else:
		fish_escape_bar.modulate = Color(1, 0.2, 0.2)

		var shake_amount = 3
		fish_escape_bar.position.x += randf_range(-shake_amount, shake_amount)
		fish_escape_bar.position.y += randf_range(-shake_amount, shake_amount)
		
	fish_reel_bar.value = fishing_con.hold_progress
	
	
