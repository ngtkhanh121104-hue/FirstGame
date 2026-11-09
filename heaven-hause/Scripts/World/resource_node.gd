
extends Node2D

signal collected(item_id: String, amount: int)

@export_enum("wood", "stone", "fiber", "berries")
var resource_type: String = "wood"

@export_range(1, 10)
var amount: int = 2

@onready var visual: Polygon2D = $Visual


func _ready() -> void:
    _update_visual()


func _update_visual() -> void:
    match resource_type:
        "wood":
            visual.color = Color("#477844")
            visual.polygon = PackedVector2Array([
                Vector2(-7, -5),
                Vector2(0, -9),
                Vector2(7, -5),
                Vector2(5, 5),
                Vector2(0, 8),
                Vector2(-5, 5)
            ])

        "stone":
            visual.color = Color("#92979a")
            visual.polygon = PackedVector2Array([
                Vector2(-7, 2),
                Vector2(-5, -5),
                Vector2(1, -8),
                Vector2(7, -3),
                Vector2(6, 5),
                Vector2(-2, 7)
            ])

        "fiber":
            visual.color = Color("#b4a64b")
            visual.polygon = PackedVector2Array([
                Vector2(-6, 5),
                Vector2(-4, -4),
                Vector2(0, 2),
                Vector2(3, -7),
                Vector2(6, 5)
            ])

        "berries":
            visual.color = Color("#bb5268")
            visual.polygon = PackedVector2Array([
                Vector2(-6, -3),
                Vector2(-2, -7),
                Vector2(3, -5),
                Vector2(6, 0),
                Vector2(3, 6),
                Vector2(-4, 5)
            ])


func interact() -> void:
    collected.emit(resource_type, amount)
    queue_free()
