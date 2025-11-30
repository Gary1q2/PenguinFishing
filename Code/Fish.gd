extends Sprite2D

signal fish_collected

var state = "fish_out"
@onready var player = get_parent().get_node("Player")

var fly_speed := 400.0          # pixels per second
var carry_offset := Vector2(0, -60)

var hover_time = 0
var hover_amplitude = 6
var hover_speed = 6


func _process(delta):
	if state == "collect":
		var target = player.global_position + carry_offset
		var dir = target - global_position
		var distance = dir.length()
		if distance < 5:
			state = "carry"
			hover_time = 0
			send_delay_fish_signal()
		else:
			global_position += dir.normalized() * fly_speed * delta

	elif state == "carry":
		hover_time += delta
		var hover_y = sin(hover_time * hover_speed) * hover_amplitude
		global_position = player.global_position + carry_offset + Vector2(0, hover_y)

func send_delay_fish_signal():
	await get_tree().create_timer(2.0).timeout
	emit_signal("fish_collected")

func fly_fish_to_player(fish_position: Vector2):
	state = "fish_out"
	visible = true
	global_position = fish_position
	var jump_height = Vector2(0, 50)
	scale = Vector2(1, 1)

	var tween_scale = get_tree().create_tween()
	var tween_pos = get_tree().create_tween()

	# 1. Small squash down first
	tween_scale.tween_property(self, "scale", Vector2(1.2, 0.8), 0.2)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# 2. Pop up bigger (overshoot)
	tween_scale.tween_property(self, "scale", Vector2(0.9 , 1.2), 0.2)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween_pos.tween_property(self, "global_position", global_position - Vector2(0, 50), 0.15)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween_pos.tween_property(self, "global_position", global_position - Vector2(0, 30), 0.2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	# 3. Settle back to normal
	tween_scale.tween_property(self, "scale", Vector2(1, 1), 0.1)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# 4. Slight anticipation pause before flying
	tween_scale.tween_interval(1)

	# 4. Start dynamic movement
	tween_scale.tween_callback(Callable(self, "_start_collecting"))


func _start_collecting():
	state = "collect"
