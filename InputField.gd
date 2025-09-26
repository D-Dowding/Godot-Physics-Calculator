extends LineEdit
class_name InputField

@onready var myPanelOwner : CalculatorPanel = owner

func _ready() -> void:
	gui_input.connect(on_mouse_click.bind(self))
	myPanelOwner.input_fields.append(self)

func on_mouse_click(event : InputEvent, input_field : LineEdit):
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed and event.as_text() == "Left Mouse Button":
		if myPanelOwner.errored_input_fields.has(input_field):
			input_field.modulate = Color(1.0, 1.0, 1.0, 1.0)
			myPanelOwner.errored_input_fields.erase(input_field)
