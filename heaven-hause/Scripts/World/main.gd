
extends Node2D

const INVENTORY_UI_SCENE = preload(
    "res://Scenes/UI/inventory_ui.tscn"
)
const TILE_SIZE := 16
const MAP_WIDTH := 80
const MAP_HEIGHT := 50
const RESOURCE_SCENE = preload(
	"res://scenes/objects/resource_node.tscn"
)
const CRAFTING_UI_SCENE = preload(
    "res://Scenes/UI/crafting_ui.tscn"
)
var collected_resources: Dictionary = {
    "wood": 0,
    "stone": 0,
    "fiber": 0,
    "berries": 0
}

var resource_label: Label
@onready var ground: TileMapLayer = $Ground


func _ready() -> void:
    _create_test_map()
    _create_resource_hud()
    _spawn_test_resources()
    var crafting_ui = CRAFTING_UI_SCENE.instantiate()
    add_child(crafting_ui)
    var inventory_ui = INVENTORY_UI_SCENE.instantiate()
    add_child(inventory_ui)

func _create_test_map() -> void:
    var image := Image.create(
        TILE_SIZE * 2,
        TILE_SIZE,
        false,
        Image.FORMAT_RGBA8
    )

    var rng := RandomNumberGenerator.new()
    rng.seed = 12345

    # Tile 0: grass
    # Tile 1: dirt
    var grass_base := Color("#568747")
    var dirt_base := Color("#98734b")

    for y in range(TILE_SIZE):
        for x in range(TILE_SIZE * 2):
            if x < TILE_SIZE:
                image.set_pixel(x, y, grass_base)
            else:
                image.set_pixel(x, y, dirt_base)

    # Pixel details for the grass tile
    for i in range(32):
        var gx := rng.randi_range(0, TILE_SIZE - 1)
        var gy := rng.randi_range(0, TILE_SIZE - 1)
        image.set_pixel(gx, gy, Color("#6b9a50"))

    # Pixel details for the dirt tile
    for i in range(28):
        var dx := rng.randi_range(TILE_SIZE, TILE_SIZE * 2 - 1)
        var dy := rng.randi_range(0, TILE_SIZE - 1)
        image.set_pixel(dx, dy, Color("#b18a5a"))

    var atlas_texture := ImageTexture.create_from_image(image)

    var atlas := TileSetAtlasSource.new()
    atlas.texture = atlas_texture
    atlas.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)

    atlas.create_tile(Vector2i(0, 0))
    atlas.create_tile(Vector2i(1, 0))

    var tile_set := TileSet.new()
    tile_set.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
    tile_set.add_source(atlas, 0)

    ground.tile_set = tile_set
    ground.clear()

    # Fill the map with grass and create a winding dirt path.
    for y in range(MAP_HEIGHT):
        var path_x := 40 + int(round(sin(float(y) * 0.3) * 4.0))

        for x in range(MAP_WIDTH):
            var atlas_coords := Vector2i(0, 0)

            if abs(x - path_x) <= 1:
                atlas_coords = Vector2i(1, 0)

            ground.set_cell(
                Vector2i(x, y),
                0,
                atlas_coords
            )

func _create_resource_hud() -> void:
    var canvas := CanvasLayer.new()
    canvas.name = "HUD"
    add_child(canvas)

    resource_label = Label.new()
    resource_label.position = Vector2(12, 12)
    resource_label.add_theme_color_override(
        "font_color",
        Color.WHITE
    )
    resource_label.add_theme_color_override(
        "font_shadow_color",
        Color.BLACK
    )
    resource_label.add_theme_constant_override(
        "shadow_offset_x",
        1
    )
    resource_label.add_theme_constant_override(
        "shadow_offset_y",
        1
    )

    canvas.add_child(resource_label)
    _update_resource_hud()


func _spawn_test_resources() -> void:
    var resource_data: Array[Dictionary] = [
        {"type": "wood", "pos": Vector2(560, 350)},
        {"type": "wood", "pos": Vector2(700, 450)},
        {"type": "wood", "pos": Vector2(820, 300)},
        {"type": "stone", "pos": Vector2(590, 480)},
        {"type": "stone", "pos": Vector2(760, 550)},
        {"type": "fiber", "pos": Vector2(900, 420)},
        {"type": "fiber", "pos": Vector2(990, 320)},
        {"type": "berries", "pos": Vector2(500, 500)}
    ]

    for data in resource_data:
        var resource = RESOURCE_SCENE.instantiate()

        resource.resource_type = data["type"]
        resource.position = data["pos"]
        resource.collected.connect(_on_resource_collected)

        add_child(resource)


func _on_resource_collected(
    item_id: String,
    amount: int
) -> void:
    if Inventory.add_item(item_id, amount):
        _update_resource_hud()

func _update_resource_hud() -> void:
    if resource_label == null:
        return

    resource_label.text = (
        "WOOD: %d   STONE: %d\nFIBER: %d   BERRIES: %d\n[I] Inventory"
        % [
            Inventory.get_item_count("wood"),
            Inventory.get_item_count("stone"),
            Inventory.get_item_count("fiber"),
            Inventory.get_item_count("berries")
        ]
    )

    resource_label.text = (
        "WOOD: %d   STONE: %d\nFIBER: %d   BERRIES: %d\n[E] Collect"
        % [
            collected_resources["wood"],
            collected_resources["stone"],
            collected_resources["fiber"],
            collected_resources["berries"]
        ]
    )
