extends CanvasLayer

@onready var  fishing_con = get_parent().get_node("FishingController")

@onready var fish_reel_label: Label = $FishReelTimer
@onready var fish_escape_label: Label = $FishEscapeTimer
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
var gradient_positions = [0.0, 0.2, 0.7, 1.0]  # normalized positions along the bar



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	fish_reel_label.text = "lala"
	fish_reel_label.visible = false
	fish_reel_label.global_position = Vector2(600, 500)
	
	reel_UI.visible = false
	

	fish_escape_label.text = "lala"
	fish_escape_label.visible = false
	fish_escape_label.global_position = Vector2(500, 500)
	
	fish_escape_bar.visible = false
	fish_escape_bar.min_value = 0
	fish_escape_bar.max_value = fishing_con.fish_escape_time
	fish_escape_bar.value = 10
	fish_escape_bar.global_position = Vector2(500, 600)
	fish_escape_bar.scale.y = 0.5
	#fish_escape_bar.rect_size = Vector2(300, 300)

	fish_reel_bar.visible = false
	fish_reel_bar.min_value = 0
	fish_reel_bar.max_value = 5
	fish_reel_bar.value = 0
	fish_reel_bar.global_position = Vector2(500, 550)
	
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
	
	fish_escape_bar.value = fishing_con.fish_escape_time
	
	var bar_percent = fish_escape_bar.value / fish_escape_bar.max_value
	
	fish_escape_bar.modulate = get_gradient_color(bar_percent)
	if bar_percent <= 0.2:
		var shake_amount = 3
		fish_escape_bar.position.x += randf_range(-shake_amount, shake_amount)
		fish_escape_bar.position.y += randf_range(-shake_amount, shake_amount)
	else:
		fish_escape_bar.global_position = Vector2(500, 600)
		
	fish_reel_bar.value = fishing_con.hold_progress
	

func get_gradient_color(t: float) -> Color:
	for i in range(gradient_positions.size() - 1):
		var p0 = gradient_positions[i]
		var p1 = gradient_positions[i+1]
		if t >= p0 and t <= p1:
			var factor = (t - p0) / (p1 - p0)
			return gradient_colors[i].lerp(gradient_colors[i+1], factor)
	return gradient_colors[-1]
