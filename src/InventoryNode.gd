extends Node

## 一个轻量级背包系统。
class_name Inventory

## 使用导表插件生成的Settings脚本路径。
@export var data:String
## 用于显示物品的父节点。
@export var inventory_base_path:NodePath
## 物品模板场景。
@export var item_template:PackedScene
## 物品模板场景中显示物品名称的节点路径。
@export var item_name:String
## 物品模板场景中显示物品数量的节点路径。
@export var item_num:String
## 物品模板场景中显示物品图标的节点路径。（可选）
@export var item_icon:String


var _data
var inventory_base:Node
var has_target_item: bool
var del_array:Array
var sort_arr:Array

var all_item:Array

## 当添加一个 Item 时发出。
signal add_a_item
## 当 add_item() 执行完毕后时发出。
signal added_item
## 当删除一个 Item 时发出。
signal del_a_item
## 当 del_item() 执行完毕后时发出。
signal deled_item
## 当分类 Item 时发出。
signal typed_item
## 当排序 Item 时发出。
signal sorted_item

func _ready():
	_data = load(data).new()
	inventory_base = get_node(inventory_base_path)
	del_array = []
	sort_arr = []

## 得到一个包含所有 Item 的数组，大概看起来像这样：[[10001, "Weapons", 2], [10002, "Weapons", 4], [10015, "Weapons", 1]]
func get_all_item() -> Array:
	var result:Array
	for i in get_children():
		var a_item:Array
		# 拿到ID、名称、数量并且添加到数组
		a_item.append(i.item_id)
		a_item.append(i.item_type)
		a_item.append(i.item_num)
		result.append(a_item)
	return result

# CC4   --BY 群确实
## 添加物品
func add_item(id:int, num:int, type:String) -> void:
	has_target_item = false
	# 判断背包是否为空：
	if inventory_base.get_child_count() == 0:
		_instance_node(id, num, type)
	else:
		# 遍历所有子节点
		for i in inventory_base.get_child_count():
			# 如果子节点的ID=当前传入ID，就是要添加相同物品 -> 改变数字
			if get_child_i(i).item_id == id:
				has_target_item = true
				break
		for i in inventory_base.get_child_count():
			# 是否需要添加相同物品
			if has_target_item:
				if _data[type].data[id].has("stack"):
					if get_child_i(i).item_id == id:
						get_child_i(i).get_node(item_num).text =\
						str(int(get_child_i(i).get_node(item_num).text) + num)
						get_child_i(i).item_num = num + int(get_child_i(i).get_node(item_num).text)
			else:
				_instance_node(id, num, type)
				break
	
	all_item.clear()
	for i in inventory_base.get_children():
		all_item.append(i.item_id)
	
	added_item.emit()

## 实际上是真正的添加物品（ add_item() 是包装过的），当这个函数执行完毕，发出 add_a_item.emit()
func _instance_node(id:int, num:int, type:String):
	var _add_node = item_template.instantiate()
	inventory_base.add_child(_add_node)
	_add_node.get_node(item_name).text = _data[type].data[id].name
	_add_node.get_node(item_num).text = str(num)
	if "icon" in _data[type].data[id]:
		_add_node.get_node(item_icon).texture = load(_data[type].data[id].icon)
	_add_node.item_id = id
	_add_node.item_type = type
	
	add_a_item.emit()

## 删除物品
func del_item(id:int, num:int, type:String) -> void:
	var now_item_num:int = 0
	for i in inventory_base.get_child_count(): # -> int
		if get_child_i(i).item_id == id:
			# 比较删除数量大小
			now_item_num = int(get_child_i(i).get_node(item_num).text)
			if now_item_num <= num:
				now_item_num = 0
				del_array.append(get_child_i(i).get_index())
			else:
				now_item_num = now_item_num - num
				del_array.append(get_child_i(i).get_index())

	for i in del_array:
		if now_item_num == 0:
			inventory_base.remove_child(inventory_base.get_child(del_array[i]))
			del_a_item.emit()
		else:
			get_child_i(i).get_node(item_num).text = str(now_item_num)
			del_a_item.emit()
	
	all_item.clear()
	for i in inventory_base.get_children():
		all_item.append(i.item_id)
	
	deled_item.emit()

# ========== 分类物品 ===========
## 分类物品
func type_item(type:String) -> void:
	if type == "all":
		for i in inventory_base.get_child_count():
			get_child_i(i).show()
	else:
		for i in inventory_base.get_child_count(): # -> int
			# 拿到当前物品分类
			if get_child_i(i).item_type == type:
				get_child_i(i).show()
			else:
				get_child_i(i).hide()
	typed_item.emit()

## 排序物品, way仅仅只有 "large_to_small" 和 "small_to_large"
func sort_item(base:String, way:String) -> void:
	sort_arr = []
	# 准备工作
	for i in inventory_base.get_child_count():
		# 数组套数组，[0, 1, 2] -> 0: 物品依据，1: 物品ID, 2.唯一ID
		var item_id_arr:Dictionary = _data[get_child_i(i).item_type].data[get_child_i(i).item_id]
		sort_arr.append([item_id_arr[base], item_id_arr.id, get_child_i(i).get_instance_id()])
	match way:
		"large_to_small":
			sort_arr.sort_custom(large_to_small)
		"small_to_large":
			sort_arr.sort_custom(small_to_large)
	# 移动节点
	for i in sort_arr.size():
		inventory_base.move_child(instance_from_id(sort_arr[i][2]), i)
	sorted_item.emit()

func large_to_small(a, b):
	if a[0] > b[0]:
		return true
	return false

func small_to_large(a, b):
	if a[0] > b[0]:
		return true
	return false

func get_child_i(num):
	return inventory_base.get_child(num)
