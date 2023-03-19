# FlowerInventory

## Overview

FlowerInventory is a lightweight backpack plugin developed for Godot Engine.

## Quick Start

Note: This plugin needs to be used with [kaluluosi/GDExcelExporter: excel table export tool for Godot (github.com)](https://github.com/kaluluosi/GDExcelExporter#readme) (later called the guide table plugin, the The data tables are called tables) used together. (Not together can also be used, just the data will be painful to write by hand)

1. first you need a template node for the item (called item template below), which needs to have child nodes that show the number of items, their names, and icons (optional). And there needs to be a script for.

2. ```gdscript
   extends Control # This item can be customized
   var item_id:int
   var item_type:String
   var item_num:int
   ```

3. You need a backpack scene that displays the backpack UI.

4. Add an Inventory node in the backpack scene:
   
   Set the node properties:
   
   Explanation:
   
   - Data：Settings script path generated using the export plugin.
   
   - Inventory Base Path：The parent node that displays the item.
   
   - Item Template：The item template scene.
   
   - Item Name：The node path that displays the item name in the item template scene.
   
   - Item Num：The node path that displays the item quantity in the item template scene.
   
   - Item Icon：The node path that displays the item icon in the item template scene (optional).

5. Add a script in your backpack scene and use the following functions:
   
   ```gdscript
   onready var inventory = $Inventory
   # Add item function
   # id: int type, the id of the item in the table
   # num: int type, the quantity of the item to be added
   # type: String type, the name of the sheet in the table, as shown in the figure below
   inventory.add_item(id, num, type)
   ```
   
   As shown in the figure above, type = Weapons
   
   ```gdscript
   # Delete item function, same parameters as above
   inventory.del_item(id, num, type)
   # Classify item function, same parameters as above
   inventory.type_item(type)
   # Sort item function
   # base：
   # String type.
   # The basis for sorting items, such as sorting by weight, needs to add relevant data in the table first, as shown in the figure below
   # way：
   # String type.
   # The order of sorting items, currently only "large_to_small" and "small_to_large", which are from large to small and from small to large, respectively
   base = weight
   ```
   
   If you want items to be stackable, you need to add the stack attribute in the Excel table, which can be any attribute or value. But as long as this attribute exists, it means that this item can be stacked, similar to this:

## Functions

```gdscript
get_all_item() -> Array
Get an array that contains all items, which looks something like this:
[[10001, "Weapons", 2], [10002, "Weapons", 4], [10015, "Weapons", 1]]
```

```gdscript
add_item(id: int, num: int, type: String) -> void
Add item
```

```gdscript
del_item(id: int, num: int, type: String) -> Array
Delete item
```

```gdscript
sort_item(base: String, way: String) -> void
Sort items, way only has "large_to_small" and "small_to_large"
```

```gdscript
type_item(type: String) -> void
Classify items
```

## 信号

```gdscript
● add_a_item()
    When an Item is added, it is emitted.
● added_item()
    Emitted when add_item() is executed.
● del_a_item()
    When an Item is deleted, it is emitted.
● deled_item()
    Emitted when del_item() is executed.
● sorted_item()
    When an Item is sorted, it is emitted.
● typed_item()
    When an Item is classified, it is emitted.
```

## Other

Thanks to the author, 确实哥.
