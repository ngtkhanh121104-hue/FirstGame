
extends CanvasLayer

var panel: PanelContainer
var recipe_list: VBoxContainer
var status_label: Label


func _ready() -> void:
    _build_ui()

    Inventory.inventory_changed.connect(_refresh)
    Crafting.crafting_completed.connect(_on_crafting_completed)
    Crafting.crafting_failed.connect(_on_crafting_failed)

    _refresh()
    panel.hide()


func _build_ui() -> void:
    panel = PanelContainer.new()
    panel.name = "CraftingPanel"
    panel.position = Vector2(70, 35)
    panel.custom_minimum_size = Vector2(500, 450)
    add_child(panel)

    var outer := VBoxContainer.new()
    outer.add_theme_constant_override("separation", 10)
    panel.add_child(outer)

    var heading := Label.new()
    heading.text = "CRAFTING"
    heading.add_theme_font_size_override("font_size", 22)
    outer.add_child(heading)

    var help_label := Label.new()
    help_label.text = "Choose a recipe and craft an item."
    outer.add_child(help_label)

    var scroll := ScrollContainer.new()
    scroll.custom_minimum_size = Vector2(450, 300)
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    outer.add_child(scroll)

    recipe_list = VBoxContainer.new()
    recipe_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(recipe_list)

    status_label = Label.new()
    status_label.text = "C / Esc: Close"
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    outer.add_child(status_label)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("open_crafting") and not event.is_echo():
        var inventory_ui = get_parent().get_node_or_null("InventoryUI")

        if panel.visible:
            panel.hide()
        else:
            if inventory_ui != null:
                inventory_ui.close_panel()
            panel.show()
            _refresh()

        get_viewport().set_input_as_handled()
        return

    if event.is_action_pressed("pause_game") and not event.is_echo():
        if panel.visible:
            panel.hide()
            get_viewport().set_input_as_handled()

func _refresh() -> void:
    if not is_instance_valid(recipe_list):
        return

    for child in recipe_list.get_children():
        recipe_list.remove_child(child)
        child.queue_free()

    var recipe_ids: Array = Crafting.get_recipe_ids()

    for recipe_id in recipe_ids:
        var recipe: Dictionary = Crafting.get_recipe(recipe_id)
        var card := VBoxContainer.new()
        card.add_theme_constant_override("separation", 4)
        recipe_list.add_child(card)

        var name_label := Label.new()
        name_label.text = str(recipe["name"])
        name_label.add_theme_font_size_override("font_size", 16)
        card.add_child(name_label)

        var description_label := Label.new()
        description_label.text = str(recipe["description"])
        description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        card.add_child(description_label)

        var ingredients_label := Label.new()
        ingredients_label.text = _get_ingredient_text(recipe)
        ingredients_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        card.add_child(ingredients_label)

        var craft_button := Button.new()
        craft_button.text = "Craft"
        craft_button.disabled = not Crafting.can_craft(recipe_id)
        craft_button.pressed.connect(_on_craft_pressed.bind(recipe_id))
        card.add_child(craft_button)

        var separator := HSeparator.new()
        card.add_child(separator)


func _get_ingredient_text(recipe: Dictionary) -> String:
    var ingredients: Dictionary = recipe["ingredients"]
    var parts: Array[String] = []

    for item_id in ingredients:
        var data = Inventory.get_item_data(item_id)
        var item_name: String = item_id

        if data != null:
            item_name = data.display_name

        var required: int = int(ingredients[item_id])
        var owned: int = Inventory.get_item_count(item_id)

        parts.append("%s: %d/%d" % [item_name, owned, required])

    return "Materials — " + ", ".join(PackedStringArray(parts))


func _on_craft_pressed(recipe_id: String) -> void:
    Crafting.craft(recipe_id)
    _refresh()


func _on_crafting_completed(item_id: String, amount: int) -> void:
    var data = Inventory.get_item_data(item_id)
    var item_name: String = item_id

    if data != null:
        item_name = data.display_name

    status_label.text = "Crafted %s x%d!" % [item_name, amount]
    _refresh()


func _on_crafting_failed(message: String) -> void:
    status_label.text = message
    
func close_panel() -> void:
    panel.hide()
