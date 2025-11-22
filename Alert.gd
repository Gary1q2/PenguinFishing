extends Sprite2D

@export var pop_scale = 1.2
@export var pop_duration = 0.2
@export var enlarge_duration = 0.1
@export var shrink_duration = 0.2

func pop_animation():
	scale = Vector2(0, 0)  # start tiny
	visible = true
	# Tween for pop
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1,1), enlarge_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)	
	tween.tween_property(self, "scale", Vector2(pop_scale, pop_scale), pop_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1,1), shrink_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
