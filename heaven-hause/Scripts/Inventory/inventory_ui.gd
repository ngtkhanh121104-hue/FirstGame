
extends CanvasLayer

var panel: PanelContainer
var item_list: VBoxContainer
var status_label: Label


func _ready() -> void:
    _build_ui()
    Inventory.inventory_changed.connect(_refresh)
    _refresh()
    panel.hide()


func _build_ui() -> void:
    panel = PanelContainer.new()
    panel.name = "InventoryPanel"
    panel.position = Vector2(100, 45)
    panel.custom_minimum_size = Vector2(440, 400)
    add_child(panel)

    var outer := VBoxContainer.new()
    outer.add_theme_constant_override("separation", 10)
    panel.add_child(outer)

    var heading := Label.new()
    heading.text = "INVENTORY"
    heading.add_theme_font_size_override("font_size", 22)
    outer.add_child(heading)

    var description := Label.new()
    description.text = "Your collected resources"
    outer.add_child(description)

    var scroll := ScrollContainer.new()
    scroll.custom_minimum_size = Vector2(400, 250)
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    outer.add_child(scroll)

    item_list = VBoxContainer.new()
    item_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(item_list)

    status_label = Label.new()
    status_label.text = "I / Esc: Close"
    outer.add_child(status_label)


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("open_inventory") and not event.is_echo():
        var crafting_ui = get_parent().get_node_or_null("CraftingUI")

        if panel.visible:
            panel.hide()
        else:
            if crafting_ui != null:
                crafting_ui.close_panel()
            panel.show()
            _refresh()

        get_viewport().set_input_as_handled()
        return

    if event.is_action_pressed("pause_game") and not event.is_echo():
        if panel.visible:
            panel.hide()
            get_viewport().set_input_as_handled()


func _refresh() -> void:
    if not is_instance_valid(item_list):
        return

    for child in item_list.get_children():
        item_list.remove_child(child)
        child.queue_free()

    var snapshot: Dictionary = Inventory.get_inventory_snapshot()
    var item_ids: Array = snapshot.keys()
    item_ids.sort()

    if item_ids.is_empty():
        var empty_label := Label.new()
        empty_label.text = "Your inventory is empty."
        item_list.add_child(empty_label)
        return

    for item_id in item_ids:
        var data: ItemData = Inventory.get_item_data(item_id)

        if data == null:
            continue

        var row := HBoxContainer.new()
        row.add_theme_constant_override("separation", 12)
        item_list.add_child(row)

        var swatch := ColorRect.new()
        swatch.color = data.icon_color
        swatch.custom_minimum_size = Vector2(18, 18)
        row.add_child(swatch)

        var name_label := Label.new()
        name_label.text = data.display_name
        name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        row.add_child(name_label)

        var count_label := Label.new()
        count_label.text = "x%d" % int(snapshot[item_id])
        row.add_child(count_label)
    
func close_panel() -> void:
    panel.hide()
