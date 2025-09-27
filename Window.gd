@tool
extends Control
class_name CalculatorWindow

signal instantiated_panel(id : int)

# This is handled like this so as to avoid having to manually set an id for each panel 
# and praying to god none of them are accidently duplicated.
# By doing this, I ensure each panel can be have a completely unique id to read via this Dictionary.
# This Dictionary holds all vital data that could be found from a CalculatorPanel, 
# neatly organizing what could've been a very painful manual validation problem.
@export var calculator_panel_data : Dictionary[int, CalculatorPanelData]:
	set(value):
		if value.size() > 0xFF:
			push_error("Max calculator panel size is 256")
			return
		
		calculator_panel_data = value

func instantiate_panel(panel_id : int):
	var p_data : CalculatorPanelData = get_panel_data_via_id(panel_id)
	if p_data == null or !p_data.scene:
		return
	if !p_data.scene.can_instantiate():
		push_error("That panel scene cannot be correctly instantiated.")
		return
	p_data.calculator_panel = p_data.scene.instantiate()
	p_data.name = p_data.calculator_panel.name
	p_data.calculator_panel.global_position = p_data.last_position
	$CalculatorPanels.add_child(p_data.calculator_panel)
	emit_signal("instantiated_panel")

func close_panel_via_obj(panel : CalculatorPanel):
	var p_data : CalculatorPanelData = get_panel_data_via_obj(panel)
	if p_data == null or p_data.calculator_panel == null:
		return
	p_data.last_position = p_data.calculator_panel.global_position
	p_data.calculator_panel.queue_free()
	
func close_panel_via_id(id : int):
	var p_data : CalculatorPanelData = get_panel_data_via_id(id)
	if p_data == null or p_data.calculator_panel == null:
		return
	p_data.last_position = p_data.calculator_panel.global_position
	p_data.calculator_panel.queue_free()
	
func close_panel_via_name(check_name : StringName):
	var p_data : CalculatorPanelData = get_panel_data_via_name(check_name)
	if p_data == null or p_data.calculator_panel == null:
		return
	p_data.last_position = p_data.calculator_panel.global_position
	p_data.calculator_panel.queue_free()

func get_panel_data_via_obj(calculator_panel : CalculatorPanel) -> CalculatorPanelData:
	for p_data in calculator_panel_data.values():
		if p_data.calculator_panel && p_data.calculator_panel == calculator_panel:
			return p_data
	#push_error("Could not find appropriate panel data.")
	return null

func get_panel_data_via_id(id : int) -> CalculatorPanelData:
	if calculator_panel_data.has(id):
		return calculator_panel_data[id]
	#push_error("Could not find appropriate panel data.")
	return null
	
func get_panel_data_via_name(check_name : StringName) -> CalculatorPanelData:
	for p_data in calculator_panel_data.values():
		if p_data.name && p_data.name == check_name:
			return p_data
	#push_error("Could not find appropriate panel data.")
	return null

#func get_unique_id() -> int:
	#var taken_ids : Array[int]
	#var new_id : int = 0x00
	#const MAX_ID : int = 0xff
	#for p_data in calculator_panel_data:
		#taken_ids.append(p_data.id)
	#for id in range(MAX_ID):
		#if !taken_ids.has(id):
			#new_id = id
			#break
	#return new_id
			#
#func does_id_already_exist(id : int) -> bool:
	#var taken_ids : Array[int]
	#for p_data in calculator_panel_data:
		#taken_ids.append(p_data.id)
	#return taken_ids.has(id)
