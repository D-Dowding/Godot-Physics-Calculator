extends MenuButton

@onready var window : Control = get_tree().get_root().get_child(0)
@export var calculator_panels : Dictionary[int, PackedScene]
var calculator_panel_last_pos : Dictionary[int, Vector2]

func _ready() -> void:
	get_popup().id_pressed.connect(id_pressed)
	for item_idx in item_count:
		get_popup().set_item_icon_max_width(item_idx, 32)
	

func id_pressed(id : int):
	if calculator_panels.keys().has(id) and calculator_panels[id].can_instantiate():
		var new_panel_obj : CalculatorPanel = calculator_panels[id].instantiate()
		for child in window.get_children():
			if child.name == new_panel_obj.name:
				get_popup().set_item_checked(id, false)
				calculator_panel_last_pos[id] = child.global_position
				child.queue_free()
				new_panel_obj.queue_free()
				return
		get_popup().set_item_checked(id, true)
		new_panel_obj.global_position = calculator_panel_last_pos[id]
		window.add_child(new_panel_obj)
		window.move_child(new_panel_obj, 1)
