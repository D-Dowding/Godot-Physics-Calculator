@tool
extends Control
class_name RatioResizer

func _ready() -> void:
	resized.connect(on_resized)
	
func on_resized():
	for child : Control in get_children():
		var max_scale = Vector2.ONE
		
		if !get_global_rect().encloses(child.get_global_rect()):
			if child.get_global_rect().end.x > get_global_rect().end.x: ## Child past right
				child.global_position.x = get_global_rect().end.x - child.get_global_rect().size.x
			if child.get_global_rect().end.y > get_global_rect().end.y: ## Child past bottom
				child.global_position.y = get_global_rect().end.y - child.get_global_rect().size.y
				
			if child.global_position.y < global_position.y: ## Child past top
				child.global_position.y = global_position.y
			if child.global_position.x < global_position.x: ## Child past left
				child.global_position.x = global_position.x
				
			if !get_global_rect().encloses(child.get_global_rect()):
				var squish_rect = Rect2(child.position, size - child.position)
				squish_rect.size = squish_rect.size.clamp(Vector2.ZERO, Vector2.INF)
				max_scale.x = clamp(max_scale.x, 0, squish_rect.size.x / child.get_global_rect().size.x)
				max_scale.y = clamp(max_scale.y, 0, squish_rect.size.y / child.get_global_rect().size.y)
				if max_scale.y > max_scale.x:
					max_scale.y = max_scale.x
				if max_scale.x > max_scale.y:
					max_scale.x = max_scale.y
					
		child.scale = max_scale
