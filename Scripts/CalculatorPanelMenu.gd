extends MenuButton

@onready var window : CalculatorWindow = get_tree().get_root().get_child(0)
const EXIT_ALL_PANELS_ID : int = 999

func _physics_process(delta: float) -> void:
	$ReferenceRect.visible = window.debug
	if window.debug:
		$ReferenceRect.size = size
		

func _ready() -> void:
	about_to_popup.connect(update_checkboxes)
	get_popup().id_pressed.connect(id_pressed)
	for item_idx in item_count:
		get_popup().set_item_icon_max_width(item_idx, 48)
	
func id_pressed(id : int):
	if id == EXIT_ALL_PANELS_ID:
		for panel_id in window.calculator_panel_data:
			window.close_panel_via_id(panel_id)
		return
	
	if !get_popup().is_item_checked(id):
		window.instantiate_panel(id)
	else:
		window.close_panel_via_id(id)

func update_checkboxes():
	for idx in item_count:
		var p_data : CalculatorPanelData = window.get_panel_data_via_id(get_popup().get_item_id(idx))
		if p_data == null:
			continue
		get_popup().set_item_checked(get_popup().get_item_id(idx), p_data.calculator_panel != null)
