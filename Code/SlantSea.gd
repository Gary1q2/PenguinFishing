extends Polygon2D

# Size of the trapezoid
var width = 1000
var height = 1500
var top_inset = 200  # how much the top corners are pushed inward

func _ready():
	# Polygon vertices (top-left, top-right, bottom-right, bottom-left)
	polygon = PackedVector2Array([
		Vector2(top_inset, 0),         # top-left
		Vector2(width - top_inset, 0), # top-right
		Vector2(width, height),        # bottom-right
		Vector2(0, height)             # bottom-left
	])

	# UV mapping to stretch the texture correctly across trapezoid
	uv = PackedVector2Array([
		Vector2(top_inset / width, 0),        # top-left
		Vector2((width - top_inset) / width, 0), # top-right
		Vector2(1, 1),                        # bottom-right
		Vector2(0, 1)                          # bottom-left
	])

	# Position the Polygon2D at top-left of the screen
	position = Vector2(-500, -500)
	
	var mat = ShaderMaterial.new()
	mat.shader = preload("res://Code/WaterTest.gdshader")
	mat.set_shader_parameter("noise", preload("res://water_texture.png"))
	material = mat
