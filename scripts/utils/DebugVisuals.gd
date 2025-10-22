extends Node
class_name DebugVisuals

# Создает простую текстуру для отладки
static func create_debug_texture(size: Vector2, color: Color) -> Texture2D:
	var image = Image.create(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)
	image.fill(color)
	
	var texture = ImageTexture.create_from_image(image)
	return texture

# Создает текстуру круга
static func create_circle_texture(radius: int, color: Color) -> Texture2D:
	var size = Vector2(radius * 2, radius * 2)
	var image = Image.create(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)
	
	var center = Vector2(radius, radius)
	for x in range(int(size.x)):
		for y in range(int(size.y)):
			var point = Vector2(x, y)
			if point.distance_to(center) <= radius:
				image.set_pixel(x, y, color)
	
	var texture = ImageTexture.create_from_image(image)
	return texture
