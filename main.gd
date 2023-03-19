@tool
extends EditorPlugin


func _enter_tree():
#	add_custom_type("Inventory", "Node", preload("res://addons/FlowerInventory/src/InventoryNode.gd"), get_editor_interface().get_base_control().get_icon("Node", "EditorIcons"))
	add_custom_type("Inventory", "Node", preload("res://addons/FlowerInventory/src/InventoryNode.gd"), preload("res://addons/FlowerInventory/src/Icon.svg"))

func _exit_tree():
	remove_custom_type("Inventory")
