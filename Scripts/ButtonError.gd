extends Resource
class_name ButtonError

@export var expression_node_bindings : Dictionary[StringName, NodePath]
@export_custom(PROPERTY_HINT_EXPRESSION, "") var evaluate_error_expression : String
@export var error_node_callable : Dictionary[NodePath, String]
@export var error_splash_text : String
