@onready var sprite = $Player     # your player sprite
@onready var rod = $FishingRod        # fishing rod sprite

func _process(delta):
	# Flip rod to match player direction
	rod.flip_h = sprite.flip_h
