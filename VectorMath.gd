extends Control

@export var remove_trailing_zeros : bool = true
@export_group("User Input Fields")
@export var AX_input_field : LineEdit
@export var AY_input_field : LineEdit
@export var BX_input_field : LineEdit
@export var BY_input_field : LineEdit
@export var S_input_field : LineEdit

@export_group("Calculation Buttons")
@export_subgroup("Additions")
@export var AX_plus_BX_button : Button
@export var AY_plus_BY_button : Button
@export_subgroup("Subtractions/A minus B")
@export var AX_minus_BX_button : Button
@export var AY_minus_BY_button : Button
@export_subgroup("Subtractions/B minus A")
@export var BX_minus_AX_button : Button
@export var BY_minus_AY_button : Button
@export_subgroup("Magnitudes")
@export var A_magnitude_button : Button
@export var B_magnitude_button : Button
@export_subgroup("Dot")
@export var A_dot_B_button : Button
@export_subgroup("Angles")
@export_subgroup("Angles/A Angles")
@export var A_angle_degrees : Button
@export var A_angle_radians : Button
@export_subgroup("Angles/B Angles")
@export var B_angle_degrees : Button
@export var B_angle_radians : Button
@export_subgroup("Angles/Angle Differences")
@export var A_B_radian_difference_button : Button
@export var A_B_degree_difference_button : Button
@export_subgroup("Normalizations/A")
@export var AX_normalized_button : Button
@export var AY_normalized_button : Button
@export_subgroup("Normalizations/B")
@export var BX_normalized_button : Button
@export var BY_normalized_button : Button
@export_subgroup("Multiplied by S/A")
@export var AX_muliplied_by_S_button : Button
@export var AY_muliplied_by_S_button : Button
@export_subgroup("Multiplied by S/B")
@export var BX_muliplied_by_S_button : Button
@export var BY_muliplied_by_S_button : Button

@export_group("Tool Buttons")
@export var reset_button : Button
@export var calculate_button : Button
@export var extras_button : Button

@export_group("Splash Text")
@export var splash_text : RichTextLabel
@export var splash_text_timer : Timer

var errored_input_fields : Array[LineEdit]
var input_fields: Array[LineEdit]
var buttons : Array[Button]
const DEFAULT_ERROR_MESSAGE : String = "Found an error in an input field! Highlighting the problem..."
const DEFAULT_INVALID_TEXT : String = "INVALID"
const DEFAULT_HIGHLIGHT_TIME : int = 4.0
const ERROR_HIGHLIGHT_RATE : float = 5.5
const ERROR_COLOR_INTENSITY : float = 3.0
var error_time_elapsed : float = -1
var validEntryFields : UserInputFlags = 0b00000
enum UserInputFlags{
	AX = 0b00001,
	AY = 0b00010,
	BX = 0b00100,
	BY = 0b01000,
	S  = 0b10000,
}

func _ready() -> void:
	buttons = [
	AX_plus_BX_button,
	AY_plus_BY_button,
	AX_minus_BX_button,
	AY_minus_BY_button,
	BX_minus_AX_button,
	BY_minus_AY_button,
	A_magnitude_button,
	B_magnitude_button,
	A_dot_B_button,
	A_angle_degrees,
	A_angle_radians,
	B_angle_degrees,
	B_angle_radians,
	A_B_radian_difference_button,
	A_B_degree_difference_button,
	AX_normalized_button,
	AY_normalized_button,
	BX_normalized_button,
	BY_normalized_button,
	AX_muliplied_by_S_button,
	AY_muliplied_by_S_button,
	BX_muliplied_by_S_button,
	BY_muliplied_by_S_button
	]
	input_fields = [
	S_input_field,
	AX_input_field,
	AY_input_field,
	BX_input_field,
	BY_input_field
	]
	
	for input_field in input_fields:
		input_field.gui_input.connect(on_mouse_click.bind(input_field))
	for button in buttons:
		if button == null:
			continue
		disable_button(button)
		button.pressed.connect(copy_to_clipboard.bind(button))
	reset_button.pressed.connect(reset_fields)
	calculate_button.pressed.connect(calculate_fields)
	extras_button.toggled.connect(toggle_extras)
	splash_text_timer.timeout.connect(on_splash_text_timer_end)
	toggle_extras(false)
	set_splash_text("", Color.WHITE)
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
		for input_field in input_fields:
			input_field.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _process(delta: float) -> void:
	validEntryFields = (
		int(AX_input_field.text.is_valid_float()) * UserInputFlags.AX | 
		int(AY_input_field.text.is_valid_float()) * UserInputFlags.AY | 
		int(BX_input_field.text.is_valid_float()) * UserInputFlags.BX |
		int(BY_input_field.text.is_valid_float()) * UserInputFlags.BY | 
		int(S_input_field.text.is_valid_float())  * UserInputFlags.S)

func toggle_extras(toggle : bool):
	$"Math/Calculations/A∠Radians".visible = toggle
	$"Math/Calculations/B∠Radians".visible = toggle
	$"Math/Calculations/A∠Degrees".visible = toggle
	$"Math/Calculations/B∠Degrees".visible = toggle

func set_splash_text(new_text : String, color : Color = Color.WHITE):
	splash_text.text = new_text
	splash_text.modulate = color

func enable_splash_text(time : float = -1):
	splash_text.visible = true
	if time != -1:
		if splash_text_timer.time_left != DEFAULT_HIGHLIGHT_TIME:
			splash_text_timer.start(DEFAULT_HIGHLIGHT_TIME)
	
func disable_splash_text():
	splash_text.visible = false

func highlight_input_field(input_field : LineEdit):
	error_time_elapsed = DEFAULT_HIGHLIGHT_TIME
	errored_input_fields.append(input_field)

func calculate_fields():
	var error_occured : bool = false
	for input_field in input_fields:
		if !input_field.text.is_valid_float():
			error_occured = true
			highlight_input_field(input_field)
	if error_occured:
		enable_splash_text(DEFAULT_HIGHLIGHT_TIME)
		set_splash_text(DEFAULT_ERROR_MESSAGE, Color.RED)
		return
	
	enable_button(AX_plus_BX_button, "%.4f" % (float(AX_input_field.text) + float(BX_input_field.text)))
	enable_button(AY_plus_BY_button, "%.4f" % (float(AY_input_field.text) + float(BY_input_field.text)))
	enable_button(AX_minus_BX_button, "%.4f" % (float(AX_input_field.text) - float(BX_input_field.text)))
	enable_button(AY_minus_BY_button, "%.4f" % (float(AY_input_field.text) - float(BY_input_field.text)))
	enable_button(BX_minus_AX_button, "%.4f" % (float(BX_input_field.text) - float(AX_input_field.text)))
	enable_button(BY_minus_AY_button, "%.4f" % (float(BY_input_field.text) - float(AY_input_field.text)))
	enable_button(A_magnitude_button, "%.4f" % Vector2(float(AX_input_field.text), float(AY_input_field.text)).length())
	enable_button(B_magnitude_button, "%.4f" % Vector2(float(BX_input_field.text), float(BY_input_field.text)).length())
	enable_button(A_angle_degrees, "%.4f" % rad_to_deg(Vector2(float(AX_input_field.text), float(AY_input_field.text)).angle()))
	enable_button(A_angle_radians, "%.4f" % Vector2(float(AX_input_field.text), float(AY_input_field.text)).angle())
	enable_button(B_angle_degrees, "%.4f" % rad_to_deg(Vector2(float(BX_input_field.text), float(BY_input_field.text)).angle()))
	enable_button(B_angle_radians, "%.4f" % Vector2(float(BX_input_field.text), float(BY_input_field.text)).angle())
	enable_button(A_B_degree_difference_button, "%.4f" % abs(rad_to_deg(Vector2(float(AX_input_field.text), float(AY_input_field.text)).angle_to(Vector2(float(BX_input_field.text), float(BY_input_field.text))))))
	enable_button(A_B_radian_difference_button, "%.4f" % abs(Vector2(float(AX_input_field.text), float(AY_input_field.text)).angle_to(Vector2(float(BX_input_field.text), float(BY_input_field.text)))))
	enable_button(AX_muliplied_by_S_button, "%.4f" % (float(AX_input_field.text) * float(S_input_field.text)))
	enable_button(AY_muliplied_by_S_button, "%.4f" % (float(AY_input_field.text) * float(S_input_field.text)))
	enable_button(BX_muliplied_by_S_button, "%.4f" % (float(BX_input_field.text) * float(S_input_field.text)))
	enable_button(BY_muliplied_by_S_button, "%.4f" % (float(BY_input_field.text) * float(S_input_field.text)))
	enable_button(AX_normalized_button, "%.4f" % (Vector2(float(AX_input_field.text), float(AY_input_field.text)).normalized().x))
	enable_button(AY_normalized_button, "%.4f" % (Vector2(float(AX_input_field.text), float(AY_input_field.text)).normalized().y))
	enable_button(BX_normalized_button, "%.4f" % (Vector2(float(BX_input_field.text), float(BY_input_field.text)).normalized().x))
	enable_button(BY_normalized_button, "%.4f" % (Vector2(float(BX_input_field.text), float(BY_input_field.text)).normalized().y))
	enable_button(A_dot_B_button, "%.4f" % Vector2(float(AX_input_field.text), float(AY_input_field.text)).dot(Vector2(float(BX_input_field.text), float(BY_input_field.text))))

func on_mouse_click(event : InputEvent, input_field : LineEdit):
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed and event.as_text() == "Left Mouse Button":
		if errored_input_fields.has(input_field):
			input_field.modulate = Color(1.0, 1.0, 1.0, 1.0)
			errored_input_fields.erase(input_field)

func on_splash_text_timer_end():
	splash_text.visible = false

func reset_fields():
	for input_field in input_fields:
		input_field.text = ""
	for button in buttons:
		if button == null:
			continue
		disable_button(button)

func disable_button(button : Button):
	button.text = DEFAULT_INVALID_TEXT
	button.disabled = true
	
func enable_button(button : Button, message : String):
	button.text = message
	button.disabled = false

func confirm_fields(...flagsToCheck : Array) -> bool:
	for flag in flagsToCheck:
		if !(validEntryFields & flag):
			return false
	return true

func copy_to_clipboard(button):
	var formatted_string : String = "%.4f" % float(button.text)
	if remove_trailing_zeros:
		formatted_string = formatted_string.rstrip("0")
		if formatted_string.ends_with("."):
			formatted_string = formatted_string.rstrip(".")
	
	if formatted_string.is_valid_float():
		enable_splash_text(DEFAULT_HIGHLIGHT_TIME)
		set_splash_text("Copied \"" + str(formatted_string) +"\" to clipboard!", Color.WHITE)
		DisplayServer.clipboard_set(formatted_string)
	else:
		push_error("Formatted string (", formatted_string, ") was not a valid float.")

func _get_current_field() -> LineEdit:
	if AX_input_field.is_editing():
		return AX_input_field
	if AY_input_field.is_editing():
		return AY_input_field
	if BX_input_field.is_editing():
		return BX_input_field
	if BY_input_field.is_editing():
		return BY_input_field
	if S_input_field.is_editing():
		return S_input_field
	return null
