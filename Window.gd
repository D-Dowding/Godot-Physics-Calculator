extends Control

var calculator_panel_id_name_dict : Dictionary[int, StringName]

func _ready():
	for calculator_panel : CalculatorPanel in get_tree().get_nodes_in_group("CalculatorPanel"):
		assert(!calculator_panel_id_name_dict.keys().has(calculator_panel.panel_id), "Found duplicate panel ids! " + str(calculator_panel_id_name_dict[calculator_panel.panel_id]) + " and " + str(calculator_panel) + " share panel id " + str(calculator_panel.panel_id))
		calculator_panel_id_name_dict[calculator_panel.panel_id] = calculator_panel.name
