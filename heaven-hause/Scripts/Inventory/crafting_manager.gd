
extends Node

signal crafting_completed(item_id: String, amount: int)
signal crafting_failed(message: String)

const RECIPES: Dictionary = {
    "planks": {
        "name": "Wooden Planks",
        "description": "Process wood into building material.",
        "output": "planks",
        "amount": 1,
        "ingredients": {
            "wood": 2
        }
    },
    "rope": {
        "name": "Rope",
        "description": "Turn plant fiber into rope.",
        "output": "rope",
        "amount": 1,
        "ingredients": {
            "fiber": 3
        }
    },
    "stone_axe": {
        "name": "Stone Axe",
        "description": "A basic tool for future upgrades.",
        "output": "stone_axe",
        "amount": 1,
        "ingredients": {
            "wood": 3,
            "stone": 2
        }
    }
}


func get_recipe_ids() -> Array:
    var recipe_ids: Array = RECIPES.keys()
    recipe_ids.sort()
    return recipe_ids


func get_recipe(recipe_id: String) -> Dictionary:
    if not RECIPES.has(recipe_id):
        return {}
    return RECIPES[recipe_id]


func can_craft(recipe_id: String) -> bool:
    var recipe: Dictionary = get_recipe(recipe_id)

    if recipe.is_empty():
        return false

    var ingredients: Dictionary = recipe["ingredients"]

    for item_id in ingredients:
        var required_amount: int = int(ingredients[item_id])

        if not Inventory.has_item(item_id, required_amount):
            return false

    return true


func get_missing_ingredients(recipe_id: String) -> Array[String]:
    var missing: Array[String] = []
    var recipe: Dictionary = get_recipe(recipe_id)

    if recipe.is_empty():
        return missing

    var ingredients: Dictionary = recipe["ingredients"]

    for item_id in ingredients:
        var required_amount: int = int(ingredients[item_id])
        var current_amount: int = Inventory.get_item_count(item_id)

        if current_amount < required_amount:
            var item_data = Inventory.get_item_data(item_id)
            var display_name: String = item_id

            if item_data != null:
                display_name = item_data.display_name

            missing.append(
                "%s (%d/%d)" % [
                    display_name,
                    current_amount,
                    required_amount
                ]
            )

    return missing


func craft(recipe_id: String) -> bool:
    var recipe: Dictionary = get_recipe(recipe_id)

    if recipe.is_empty():
        crafting_failed.emit("Unknown recipe.")
        return false

    if not can_craft(recipe_id):
        var missing := get_missing_ingredients(recipe_id)
        crafting_failed.emit(
    "Missing ingredients: " + ", ".join(PackedStringArray(missing))
    )
        return false

    var ingredients: Dictionary = recipe["ingredients"]

    # Consume the ingredients.
    for item_id in ingredients:
        var required_amount: int = int(ingredients[item_id])

        if not Inventory.remove_item(item_id, required_amount):
            crafting_failed.emit("Could not consume ingredients.")
            return false

    # Add the crafted item to Inventory.
    var output_id: String = recipe["output"]
    var output_amount: int = int(recipe["amount"])

    if not Inventory.add_item(output_id, output_amount):
        crafting_failed.emit("Could not add crafted item.")
        return false

    crafting_completed.emit(output_id, output_amount)
    return true
