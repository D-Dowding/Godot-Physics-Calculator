extends Button
class_name CalculationButton

@export_custom(PROPERTY_HINT_EXPRESSION, "") var expression_text : String = ""
@export var remove_trailing_zeros : bool = true
@onready var expression : Expression = Expression.new()
@onready var myPanelOwner : CalculatorPanel = owner
@onready var window : CalculatorWindow = get_tree().get_root().get_child(0)
const DEFAULT_INVALID_TEXT : String = "INVALID"

signal copied_to_clipboard(string : String)

func _ready() -> void:
	disable()
	pressed.connect(copy_to_clipboard.bind(self))
	myPanelOwner.buttons.append(self)
	
func copy_to_clipboard(button):
	var formatted_string : String = "%.4f" % float(button.text)
	if remove_trailing_zeros:
		formatted_string = formatted_string.rstrip("0")
		if formatted_string.ends_with("."):
			formatted_string = formatted_string.rstrip(".")
	
	if formatted_string.is_valid_float():
		##TODO
		myPanelOwner.render_splash_text("Copied \"" + str(formatted_string) +"\" to clipboard!", Color.WHITE, myPanelOwner.DEFAULT_HIGHLIGHT_TIME)
		DisplayServer.clipboard_set(formatted_string)
		copied_to_clipboard.emit(formatted_string)
	else:
		push_error("Formatted string (", formatted_string, ") was not a valid float.")

func disable():
	text = DEFAULT_INVALID_TEXT
	disabled = true
	
func enable(message : String = expression_text):
	if message.trim_prefix(" ").trim_suffix(" ") == "":
		push_warning(self, " message is blank, nothing can be read from this.")
		return
		
	#var testa : Transform2D = Transform2D.IDENTITY
	#var testb : Basis = Basis.IDENTITY
	#var testc : Projection = Projection.IDENTITY
	
	if name == "Button" and $"..".name == "A^-1":
		print_debug("testing")
		print_debug(Basis(Vector3(4, 4, 1), Vector3(4, 7, 9), Vector3(8, 6, 2)).inverse())
		print_debug(Transform2D(Vector2(3, 5), Vector2(4, 7), Vector2.ZERO).determinant())
		print_debug(Transform2D(Vector2(float(myPanelOwner.input_fields["A00"].text), float(myPanelOwner.input_fields["A01"].text)), Vector2(float(myPanelOwner.input_fields["A10"].text), float(myPanelOwner.input_fields["A11"].text)), Vector2.ZERO).affine_inverse().x.y)
		print_debug(float(1) / ((float(myPanelOwner.input_fields["A00"].text) * float(myPanelOwner.input_fields["A11"].text)) - (float(myPanelOwner.input_fields["A01"].text) * float(myPanelOwner.input_fields["A10"].text))) * -float(myPanelOwner.input_fields["A01"].text))
		print_debug(Basis(Vector3(4, 4, 1), Vector3(4, 7, 9), Vector3(8, 6, 2)) * Basis(Vector3(3, 5, 5), Vector3(3, 2, 7), Vector3(8, 9, 1)))
		
		
	var error : Error = expression.parse(message, ["field"])
	if error != OK:
		printerr(expression.get_error_text())
		push_error(expression.get_error_text(), ", ", error)
		return
		
	var result = expression.execute([myPanelOwner.input_fields], self)
	if expression.has_execute_failed():
		printerr(expression.get_error_text())
		push_error(expression.get_error_text())
		return
	
	if is_nan(float(result)):
		myPanelOwner.render_splash_text("Error in fields caused NaN value", Color.LIGHT_CORAL, myPanelOwner.DEFAULT_HIGHLIGHT_TIME)
	
	## NOTE: Result should be a float
	text = "%.4f" % result
	disabled = false
