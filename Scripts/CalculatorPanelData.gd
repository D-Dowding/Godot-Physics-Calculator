extends Resource
class_name CalculatorPanelData

## DEPRECATED: Old place for id. id is now handled via the integer keys of the Dictionary on the Window class
#@export_range(0x00, 0xFF) var id : int
@export var scene : PackedScene
var last_position : Vector2 = Vector2.ZERO
var name : StringName
var calculator_panel : CalculatorPanel
