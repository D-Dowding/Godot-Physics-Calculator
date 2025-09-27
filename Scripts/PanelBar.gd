@tool
extends Panel
class_name PanelBar

@export var custom_icon : Texture2D
@export var custom_title : StringName

var offset : Vector2
var dragging : bool = false
@onready var parent : CalculatorPanel
@onready var panel_title : Label = $PanelSplash/PanelTitle
@onready var panel_icon : TextureRect = $PanelSplash/PanelIcon
@onready var panel_exit_button : TextureButton = $PanelExitButton
@onready var window : CalculatorWindow

func _ready() -> void:
	try_set_panel_title()
	try_set_panel_icon()
	if get_owner() and get_owner() is CalculatorPanel:
		parent = get_owner()
	if get_tree().get_root().get_child(0) is CalculatorWindow:
		window = get_tree().get_root().get_child(0)
	gui_input.connect(drag)
	$PanelSplash.gui_input.connect(drag)
	if parent:
		panel_exit_button.pressed.connect(parent.close_panel)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		try_set_panel_title()
		try_set_panel_icon()
		return
	
	if !Engine.is_editor_hint() and window and parent:
		## Drag window
		if dragging:
			mouse_default_cursor_shape = CursorShape.CURSOR_DRAG
			$PanelSplash.mouse_default_cursor_shape = CursorShape.CURSOR_DRAG
			parent.global_position = get_global_mouse_position() + offset
		else:
			mouse_default_cursor_shape = CursorShape.CURSOR_ARROW
			$PanelSplash.mouse_default_cursor_shape = CursorShape.CURSOR_ARROW
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

func try_set_panel_title():
	if custom_title != null and panel_title.text != custom_title:
		panel_title.text = custom_title
		
func try_set_panel_icon():
	if custom_icon != null and panel_icon.texture != custom_icon:
		panel_icon.texture = custom_icon
