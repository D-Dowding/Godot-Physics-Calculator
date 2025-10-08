extends Control
class_name CalculatorPanel

@export var extra_calculations : Array[Control]
@export var panel_errors : Dictionary[StringName, ButtonError]

@export_group("Tool Buttons")
@export var reset_button : Button
@export var calculate_button : Button
@export var extras_button : Button

@export_group("Splash Text")
@export var splash_text : RichTextLabel
@export var splash_text_timer : Timer

@onready var window : CalculatorWindow = get_tree().get_root().get_child(0)

var errored_input_fields : Array[InputField]
var input_fields: Dictionary[String, InputField]
var buttons : Array[CalculationButton]
const DEFAULT_ERROR_MESSAGE : String = "Found an error in an input field! Highlighting the problem..."
const DEFAULT_ERROR_COLOR : Color = Color.LIGHT_CORAL
const DEFAULT_HIGHLIGHT_TIME : float = 4.0
const ERROR_HIGHLIGHT_RATE : float = 5.5
const ERROR_COLOR_INTENSITY : float = 3.0
var error_time_elapsed : float = -1
var splash_text_queue : Array[SplashText]

signal calculator_panel_closed(panel : CalculatorPanel)

func _ready() -> void:
	reset_button.pressed.connect(reset_fields)
	calculate_button.pressed.connect(calculate_fields)
	extras_button.toggled.connect(toggle_extras)
	toggle_extras(false)
	set_splash_text_visibility(false)

func _physics_process(delta: float) -> void:
	$ReferenceRect.visible = window.debug
	if window.debug:
		$ReferenceRect.size = size
	
	## Handle Splash text queue
	if !splash_text_queue.is_empty():
		set_splash_text_visibility(true)
		splash_text.text = "(" + str(splash_text_queue.size()) + ") " + str(splash_text_queue[0].text)
		splash_text.modulate = splash_text_queue[0].color
		splash_text.modulate.a = clamp(splash_text_queue[0].time, 0, 1)
		splash_text_queue[0].time -= delta
		if splash_text_queue[0].time <= 0:
			splash_text_queue.remove_at(0) 
			## NOTE: This could be bad.
			## This would be better off removing the last element so it doesn't have to adjust every element's index on removal.
			## SplashText lists are typically small though, so it's not a huuuuuuge deal, but error lists could become much larger in the future.
	else:
		set_splash_text_visibility(false)
	
	## Highlight errored fields
	if error_time_elapsed > 0:
		error_time_elapsed -= delta
		error_time_elapsed = clamp(error_time_elapsed, 0, DEFAULT_HIGHLIGHT_TIME)
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
			
class SplashText:
	var text : String
	var color : Color
	var time : float
	var clear_queue : bool
	func _init(new_text : String, new_color : Color = Color.WHITE, new_time : float = DEFAULT_HIGHLIGHT_TIME, do_clear_queue : bool = false) -> void:
		text = new_text
		color = new_color
		time = new_time
		clear_queue = do_clear_queue

func queue_splash_text(splash_text_obj : SplashText):
	if splash_text_obj.clear_queue:
		splash_text_queue.clear()
	for splash_text_element in splash_text_queue:
		if splash_text_element.text == splash_text_obj.text:
			return ## Don't allow two matching splash texts to exist
	splash_text_queue.append(splash_text_obj)
	
func set_splash_text_visibility(visibility : bool):
	splash_text.visible = visibility

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
		queue_splash_text(SplashText.new(DEFAULT_ERROR_MESSAGE, DEFAULT_ERROR_COLOR, DEFAULT_HIGHLIGHT_TIME, true))
		return
	
	for button : CalculationButton in buttons:
		button.enable()
		
	evaluate_errors()

func evaluate_errors():
	var error : Error
	var result : bool
	var expression : Expression = Expression.new()
	for button_error : ButtonError in panel_errors.values():
		error = expression.parse(button_error.evaluate_error_expression, button_error.expression_node_bindings.keys())
		var bind_nodes : Array[Node]
		for node_path : NodePath in button_error.expression_node_bindings.values():
			bind_nodes.append(get_node(node_path))
		result = expression.execute(bind_nodes, self)
		if result:
			for node_path : NodePath in button_error.error_node_callable.keys():
				get_node(node_path).call(button_error.error_node_callable[node_path])
			queue_splash_text(SplashText.new(button_error.error_splash_text, DEFAULT_ERROR_COLOR, DEFAULT_HIGHLIGHT_TIME, false))

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

func close_panel():
	emit_signal("calculator_panel_closed", self)
	window.close_panel_via_obj(self)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).is_pressed():
		print_debug("Focusing Panel " + str(self) +  " to Front")
		window.calculator_panels_node.move_child(self, window.calculator_panels_node.get_child_count() - 1)
