extends LineEdit
class_name InputField

@onready var window : CalculatorWindow = get_tree().get_root().get_child(0)
@onready var myPanelOwner : CalculatorPanel = owner
## The id of this InputField.
## This value is REQUIRED for a scene with an InputField to run.
## The id is used by the CalculationButton to get a field from the CalculationPanel.
@export var id : String
@export var default_string : String

func _ready() -> void:
	assert( id.trim_prefix(" ").trim_suffix(" ") != "", "ERROR: " + str(self) + " is missing an id! Please set one in the inspector!")
	gui_input.connect(on_mouse_click.bind(self))
	myPanelOwner.input_fields[id] = self

func on_mouse_click(event : InputEvent, input_field : LineEdit):
	if event is InputEventMouseButton and (event as InputEventMouseButton).is_pressed():
		# Move CalculatorPanel to front
		window.calculator_panels_node.move_child(myPanelOwner, window.calculator_panels_node.get_child_count() - 1)
		if myPanelOwner.errored_input_fields.has(input_field):
			input_field.modulate = Color(1.0, 1.0, 1.0, 1.0)
			myPanelOwner.errored_input_fields.erase(input_field)
