extends Node

@export var data:String
@export var inventory_base_path:NodePath
@export var item_template:PackedScene
@export var item_name:String
@export var item_num:String
@export var item_icon:String

var _data
var inventory_base
var has_target_item: bool
var del_array:Array
var sort_arr:Array

func _ready():
    _data = load(data).new()
    inventory_base = get_node(inventory_base_path)
    del_array = []
    sort_arr = []

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
                if _data[type].data[id].has("stack"):
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
    _add_node.get_node(item_name).text = _data[type].data[id].name
    _add_node.get_node(item_num).text = str(num)
    if "icon" in _data[type].data[id]:
        _add_node.get_node(item_icon).texture = load(_data[type].data[id].icon)
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

func large_to_small(a, b):
    if a[0] > b[0]:
        return true
        return false
        
func small_to_large(a, b):
    if a[0] < b[0]:
        return true
        return false

func get_child_i(num):
    return inventory_base.get_child(num)
