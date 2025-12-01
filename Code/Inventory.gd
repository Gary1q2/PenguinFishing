extends CanvasLayer

var fish_data = {
	"trash": preload("res://Fish/trash.png"),
	
	"seaweed": preload("res://Fish/seaweed.png"),
	"chest": preload("res://Fish/chest.png"),
	
	"goldfish": preload("res://Fish/goldfish.png"),
	"shrimp": preload("res://Fish/shrimp.png"),
	"sardine": preload("res://Fish/sardine.png"),

	"clam": preload("res://Fish/clam.png"),	

	"crab": preload("res://Fish/crab.png"),
	"octopus": preload("res://Fish/octopus.png"),
	
	"eel": preload("res://Fish/eel.png"),
	"jellyfish": preload("res://Fish/jellyfish.png"),
	
	"snapper": preload("res://Fish/snapper.png"),
	"mackerel": preload("res://Fish/mackerel.png"),
	"salmon": preload("res://Fish/salmon.png"),
	"swordfish": preload("res://Fish/swordfish.png"),
	
	"mahimahi": preload("res://Fish/mahimahi.png"),
	"shark": preload("res://Fish/shark.png"),
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
	
	var shader = Shader.new()
	shader = preload("res://Code/Blur.gdshader")
	
	# initialize all fish as uncaught
	for fish_name in fish_data.keys():
		caught_fish[fish_name] = false

	var grid = $Panel/GridContainer

	# create a TextureRect slot for each fish
	for fish_name in fish_data.keys():
		var slot = TextureRect.new()
		slot.texture = fish_data[fish_name]            # assign fish sprite
		slot.modulate = Color(0, 0, 0, 1)             # start blacked-out
		slot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		var mat = ShaderMaterial.new()
		mat.shader = shader
		#slot.material = mat
		#slot.material.set("shader_parameter/blur_size", 10)   # initial blur
			
		grid.add_child(slot)

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

		print('caught ', name, '    = ', caught_fish[name])
		if caught_fish[name] == true:
			node.modulate = Color(1, 1, 1, 1)   # normal
			#node.material.set("shader_parameter/blur_size", 0)
		else:
			node.modulate = Color(0, 0, 0, 1)   # blacked-out silhouette
			#node.material.set("shader_parameter/blur_size", 4)
