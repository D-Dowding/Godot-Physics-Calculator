extends Control
class_name CalculatorPanel

@export_range(0x00, 0xFF) var panel_id : int = 0x00
@export var extra_calculations : Array[Control]

@export_group("Tool Buttons")
@export var reset_button : Button
@export var calculate_button : Button
@export var extras_button : Button

@export_group("Splash Text")
@export var splash_text : RichTextLabel
@export var splash_text_timer : Timer

## This needs to be here because Control changes based on window size, whereas rect does not
@onready var rect = $Rect

var errored_input_fields : Array[InputField]
var input_fields: Dictionary[String, InputField]
var buttons : Array[CalculationButton]
const DEFAULT_ERROR_MESSAGE : String = "Found an error in an input field! Highlighting the problem..."
const DEFAULT_HIGHLIGHT_TIME : float = 4.0
const ERROR_HIGHLIGHT_RATE : float = 5.5
const ERROR_COLOR_INTENSITY : float = 3.0
var error_time_elapsed : float = -1

func _ready() -> void:
	reset_button.pressed.connect(reset_fields)
	calculate_button.pressed.connect(calculate_fields)
	extras_button.toggled.connect(toggle_extras)
	splash_text_timer.timeout.connect(on_splash_text_timer_end)
	toggle_extras(false)
	disable_splash_text()

func _physics_process(delta: float) -> void:
	if error_time_elapsed > 0:
		error_time_elapsed -= delta
		error_time_elapsed = clamp(error_time_elapsed, 0, DEFAULT_HIGHLIGHT_TIME)
		## Highlight errored fields
		for input_field in errored_input_fields:
			input_field.modulate.r = ERROR_COLOR_INTENSITY * sin(ERROR_HIGHLIGHT_RATE * error_time_elapsed - PI/2) + ERROR_COLOR_INTENSITY + 1
			input_field.modulate.b = 1
			input_field.modulate.g = 1
	elif error_time_elapsed == 0:
		error_time_elapsed = -1
		errored_input_fields.clear()
		for input_field in input_fields.values():
			input_field.modulate = Color(1.0, 1.0, 1.0, 1.0)

func toggle_extras(toggle : bool):
	for calculation in extra_calculations:
		calculation.visible = toggle
			
func render_splash_text(new_text : String, color : Color = Color.WHITE, time : float = -1):
	splash_text.text = new_text
	splash_text.modulate = color
	splash_text.visible = true
	if time != -1:
		if splash_text_timer.time_left != DEFAULT_HIGHLIGHT_TIME:
			splash_text_timer.start(DEFAULT_HIGHLIGHT_TIME)
	
func disable_splash_text():
	splash_text.visible = false
	
func on_splash_text_timer_end():
	disable_splash_text()

func highlight_input_field(input_field : LineEdit):
	error_time_elapsed = DEFAULT_HIGHLIGHT_TIME
	errored_input_fields.append(input_field)

func calculate_fields():
	var error_occured : bool = false
	for input_field in input_fields.values():
		if !input_field.text.is_valid_float():
			error_occured = true
			highlight_input_field(input_field)
			
	if error_occured:
		render_splash_text(DEFAULT_ERROR_MESSAGE, Color.LIGHT_CORAL, DEFAULT_HIGHLIGHT_TIME)
		return
	
	for button in buttons:
		button.enable()

func reset_fields():
	for input_field in input_fields.values():
		input_field.text = input_field.default_string
	for button in buttons:
		button.disable()

func _get_current_field() -> LineEdit:
	for input_field in input_fields.values():
		if input_field.is_editing():
			return input_field
	return null
