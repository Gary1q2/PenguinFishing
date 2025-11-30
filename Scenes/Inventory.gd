extends CanvasLayer

# -----------------------------
# 1. Fish dictionary
# Keys = fish names, Values = preloaded textures
# -----------------------------
var fish_data = {
	"goldfish": preload("res://Fish/goldfish.png"),
	"shrimp": preload("res://Fish/shrimp.png"),
	"sardine": preload("res://Fish/sardine.png"),
	"snapper": preload("res://Fish/snapper.png"),
	"mackerel": preload("res://Fish/mackerel.png"),
	"salmon": preload("res://Fish/salmon.png"),
}

# -----------------------------
# 2. Fish caught state
# All fish start as uncaught (false)
# -----------------------------
var caught_fish = {}

# -----------------------------
# 3. Array of slot objects
# Each element = { "name": fish_name, "node": TextureRect }
# -----------------------------
var slots = []

# -----------------------------
# 4. Ready function
# -----------------------------
func _ready():
	# initialize all fish as uncaught
	for fish_name in fish_data.keys():
		caught_fish[fish_name] = false

	var hbox = $Panel/HBoxContainer

	# create a TextureRect slot for each fish
	for fish_name in fish_data.keys():
		var slot = TextureRect.new()
		slot.texture = fish_data[fish_name]            # assign fish sprite
		slot.modulate = Color(0, 0, 0, 1)             # start blacked-out
		slot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hbox.add_child(slot)

		# store in slots array
		slots.append({
			"name": fish_name,
			"node": slot
		})

# -----------------------------
# 5. Input to toggle inventory
# -----------------------------
func _input(event):
	if event.is_action_pressed("inventory_toggle"):
		$Panel.visible = not $Panel.visible

# -----------------------------
# 6. Catch a fish
# -----------------------------
func catch_fish(fish_name: String):
	if fish_name in caught_fish:
		caught_fish[fish_name] = true
		_update_slots()

# -----------------------------
# 7. Update slots visuals
# -----------------------------
func _update_slots():
	for slot_data in slots:
		var name = slot_data["name"]
		var node = slot_data["node"]
		node.texture = fish_data[name]
		if caught_fish[name]:
			node.modulate = Color(1, 1, 1, 1)   # normal
		else:
			node.modulate = Color(0, 0, 0, 1)   # blacked-out silhouette
