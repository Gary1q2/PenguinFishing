extends CanvasLayer

@onready var  fishing_con = get_parent().get_node("FishingController")

@onready var fish_reel_label: Label = $FishReelTimer
@onready var fish_escape_label: Label = $FishEscapeTimer
@onready var rod_tension_label: Label = $RodTension

@onready var fish_caught_label: Label = $FishName

@onready var reel_UI: Sprite2D = $ReelUI

@onready var fish_escape_bar: ProgressBar = $FishEscapeBar
@onready var fish_reel_bar: ProgressBar = $FishReelBar



@onready var player = get_parent().get_node("Player")


var gradient_colors = [
	Color(1, 0.2, 0.2),   # red
	Color(1, 0.5, 0),    # orange
	Color(1, 1, 0.2),    # yellow
	Color(0.2, 1, 0.2),  # green
]
var gradient_positions = [0, 0.25, 0.75, 1.0]  # normalized positions along the bar

var fish_escape_bar_start_pos;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	fish_reel_label.text = "lala"
	fish_reel_label.visible = false
	fish_reel_label.global_position = Vector2(600, 500)

	var x_pos = 350
	var y_pos = 700

	fish_caught_label.visible = false
	
	var viewport_size = get_viewport().size
	print(viewport_size)
	
	reel_UI.visible = false
	reel_UI.global_position = Vector2(x_pos, y_pos + 100)
	
	rod_tension_label.text = "69"
	rod_tension_label.visible = false
	rod_tension_label.global_position = Vector2(x_pos + 100, y_pos - 100)
	

	fish_escape_label.text = "lala"
	fish_escape_label.visible = false
	fish_escape_label.global_position = Vector2(x_pos + 100, y_pos)
	
	fish_escape_bar.visible = false
	fish_escape_bar.min_value = 0
	fish_escape_bar.max_value = fishing_con.fish_escape_time
	fish_escape_bar.value = 10
	fish_escape_bar.global_position = Vector2(x_pos + 100, y_pos + 25)
	fish_escape_bar.scale.y = 0.5
	fish_escape_bar_start_pos = fish_escape_bar.global_position
	#fish_escape_bar.rect_size = Vector2(300, 300)

	fish_reel_bar.visible = false
	fish_reel_bar.min_value = 0
	fish_reel_bar.max_value = 5
	fish_reel_bar.value = 0
	fish_reel_bar.global_position = Vector2(x_pos+100, y_pos+50)

func show_catch_text(fish_name: String):
	fish_caught_label.text = "You caught a  %s!" % fish_name
	fish_caught_label.visible = true

	# Fade in and fade out using Tween
	var tween = get_tree().create_tween()

	# Fade in
	tween.tween_property(fish_caught_label, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Wait 5 seconds then fade out
	tween.tween_interval(5.0)
	tween.tween_property(fish_caught_label, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func():
		fish_caught_label.visible = false
	)


func set_fish_escape_bar_max(value):
	fish_escape_bar.max_value = value
	
func set_fish_reel_bar_max(value):
	fish_reel_bar.max_value = value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	if fishing_con.is_holding:
		reel_UI.rotation -= delta * 10

	fish_reel_label.text = "%.2f" % fishing_con.hold_progress
	fish_escape_label.text = "%.2f" % fishing_con.fish_escape_time
	rod_tension_label.text = "%.2f" % fishing_con.rod_tension_time
	
	fish_escape_bar.value = fishing_con.fish_escape_time
	
	var bar_percent = fish_escape_bar.value / fish_escape_bar.max_value
	
	fish_escape_bar.modulate = get_gradient_color(bar_percent)
	if bar_percent <= 0.2:
		var shake_amount = 3
		if randf() < 0.5:
			fish_escape_bar.position.x += randf_range(-shake_amount, shake_amount)
			#fish_escape_bar.position.y += randf_range(-shake_amount, shake_amount)
	else:
		fish_escape_bar.global_position = fish_escape_bar_start_pos
		
	fish_reel_bar.value = fishing_con.hold_progress
	

func get_gradient_color(t: float) -> Color:
	for i in range(gradient_positions.size() - 1):
		var p0 = gradient_positions[i]
		var p1 = gradient_positions[i+1]
		if t >= p0 and t <= p1:
			var factor = (t - p0) / (p1 - p0)
			return gradient_colors[i].lerp(gradient_colors[i+1], factor)
	return gradient_colors[-1]
