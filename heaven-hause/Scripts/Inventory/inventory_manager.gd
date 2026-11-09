
extends Node

signal inventory_changed
signal item_added(item_id: String, amount: int)
signal item_removed(item_id: String, amount: int)

const STARTING_SLOTS := 20

var item_database: Dictionary = {}
var items: Dictionary = {}


func _ready() -> void:
    _register_item("wood", "Wood", "Wood collected from trees.", 99, Color("#9b7047"))
    _register_item("stone", "Stone", "A piece of stone.", 99, Color("#969da3"))
    _register_item("fiber", "Plant Fiber", "Useful plant material.", 99, Color("#b6a64f"))
    _register_item("berries", "Berries", "Wild berries that can be eaten.", 99, Color("#c94e70"))
    _register_item("planks", "Wooden Planks", "Processed wooden planks.", 99, Color("#bd9567"))
    _register_item("rope", "Rope", "Strong rope made from plant fiber.", 99, Color("#d5bd83"))
    _register_item("stone_axe", "Stone Axe", "A basic stone chopping tool.", 1, Color("#777f88"))


func _register_item(
    id: String,
    item_name: String,
    item_description: String,
    stack_limit: int,
    color: Color
) -> void:
    var data := ItemData.new()
    data.id = id
    data.display_name = item_name
    data.description = item_description
    data.max_stack = stack_limit
    data.icon_color = color

    item_database[id] = data


func get_item_data(item_id: String) -> ItemData:
    return item_database.get(item_id) as ItemData


func get_item_count(item_id: String) -> int:
    return int(items.get(item_id, 0))


func add_item(item_id: String, amount: int = 1) -> bool:
    if amount <= 0 or not item_database.has(item_id):
        return false

    items[item_id] = get_item_count(item_id) + amount

    item_added.emit(item_id, amount)
    inventory_changed.emit()
    return true


func remove_item(item_id: String, amount: int = 1) -> bool:
    if amount <= 0:
        return false

    var current_count := get_item_count(item_id)

    if current_count < amount:
        return false

    var remaining := current_count - amount

    if remaining == 0:
        items.erase(item_id)
    else:
        items[item_id] = remaining

    item_removed.emit(item_id, amount)
    inventory_changed.emit()
    return true


func has_item(item_id: String, amount: int = 1) -> bool:
    return get_item_count(item_id) >= amount


func get_inventory_snapshot() -> Dictionary:
    return items.duplicate()
