extends Node

export(String) var data
export(NodePath) var inventory_base_path
export(PackedScene) var item_template
export(String) var item_name
export(String) var item_num
export(String) var item_icon

var _data
var inventory_base
var has_target_item: bool
var del_array:Array
var sort_dic:Dictionary
var sort_arr:Array
var sort_node:Array

func _ready():
	_data = load(data).new()
	inventory_base = get_node(inventory_base_path)
	del_array = []
	sort_dic = {}
	sort_arr = []
	sort_node = []

# CC4   --BY 群确实
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
				if _data[type].data()[id].has("stack"):
					if get_child_i(i).item_id == id:
						get_child_i(i).get_node(item_num).text =\
						str(int(get_child_i(i).get_node(item_num).text) + num)
						get_child_i(i).item_num = num + int(get_child_i(i).get_node(item_num).text)
			else:
				_instance_node(id, num, type)
				break
				

func _instance_node(id:int, num:int, type:String):
	var _add_node = item_template.instance()
	inventory_base.add_child(_add_node)
	_add_node.get_node(item_name).text = _data[type].data()[id].name
	_add_node.get_node(item_num).text = str(num)
	if "icon" in _data[type].data()[id]:
		_add_node.get_node(item_icon).texture = load(_data[type].data()[id].icon)
	_add_node.item_id = id
	_add_node.item_type = type

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
		else:
			print_debug("没找到ID")
	for i in del_array:
		if now_item_num == 0:
			inventory_base.remove_child(inventory_base.get_child(del_array[i]))
		else:
			get_child_i(i).get_node(item_num).text = str(now_item_num)

# ========== 分类物品 ===========
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
				

# 两个参数 依据（重量、价值）方法（从小到大、从大到小）
func sort_item(base:String, way:String) -> void:
	for i in inventory_base.get_child_count():
		# 排列顺序数组.添加（数据表.类型.data().物品ID.排列依据）
		# _data[type].data()[id].name
		# key是排序依据 value是索引
		sort_dic[_data[get_child_i(i).item_type].data()[get_child_i(i).item_id][base]] = get_child_i(i).get_index()
		sort_arr.append(_data[get_child_i(i).item_type].data()[get_child_i(i).item_id][base])
		sort_node.append(get_child_i(i).get_instance_id()) # -> int
	# 排序数组
	for i in inventory_base.get_child_count():
		if way == "small_to_large":
			sort_arr.sort()
		elif way == "large_to_small":
			sort_arr.sort()
			sort_arr.invert()
		else:
			print_debug("Error: No correct sorting (way) ")
	for i in sort_node.size():
		print(i)
		print(sort_arr[0])
		print(sort_dic[sort_arr[i]])
		inventory_base.move_child(instance_from_id(sort_node[i]), sort_dic[sort_arr[i]])


func get_child_i(num):
	return inventory_base.get_child(num)
