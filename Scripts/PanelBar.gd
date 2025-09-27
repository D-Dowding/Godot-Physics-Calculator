@tool
extends Panel
class_name PanelBar

var offset : Vector2
var dragging : bool = false
@onready var parent : CalculatorPanel
@onready var panel_title : Label = $PanelTitle
@onready var panel_exit_button : TextureButton = $PanelExitButton
@onready var window : Control

func _ready() -> void:
	if get_owner() and get_owner() is CalculatorPanel:
		parent = get_owner()
		panel_title.text = parent.name
	if get_tree().get_root().get_child(0).name == "Window":
		window = get_tree().get_root().get_child(0)
	gui_input.connect(drag)
	panel_exit_button.pressed.connect(close_panel)

func _process(delta: float) -> void:
	if Engine.is_editor_hint() and parent and parent.name != panel_title.text:
		panel_title.text = parent.name
		return
	
	if !Engine.is_editor_hint():
		## Drag window
		if dragging:
			mouse_default_cursor_shape = CursorShape.CURSOR_DRAG
			parent.global_position = get_global_mouse_position() + offset
		else:
			mouse_default_cursor_shape = CursorShape.CURSOR_ARROW
		## Clamp to window size
		if window.size > parent.rect.size:
			parent.global_position = global_position.clamp(Vector2.ZERO, window.size - parent.rect.size)
		else:
			parent.global_position = global_position.clamp(Vector2.ZERO, window.size - panel_title.size)
	
func drag(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		dragging = true
		offset = global_position - get_global_mouse_position()
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT and !(event as InputEventMouseButton).is_pressed():
		dragging = false

func close_panel():
	parent.queue_free()
