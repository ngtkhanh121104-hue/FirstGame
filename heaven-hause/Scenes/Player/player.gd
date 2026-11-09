
extends CharacterBody2D

@export var move_speed: float = 100.0

@onready var body_visual: Polygon2D = $BodyVisual
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
    # Create a temporary pixel-style character.
    body_visual.polygon = PackedVector2Array([
        Vector2(-4, -5),
        Vector2(4, -5),
        Vector2(5, 2),
        Vector2(0, 6),
        Vector2(-5, 2)
    ])
    body_visual.color = Color("#e8c56a")

    # Create a circular collision shape.
    var circle := CircleShape2D.new()
    circle.radius = 5.0
    collision_shape.shape = circle

    # Configure the camera to follow the player.
    camera.enabled = true
    camera.position_smoothing_enabled = true
    camera.position_smoothing_speed = 6.0


func _physics_process(_delta: float) -> void:
    var input_direction := Input.get_vector(
        "move_left",
        "move_right",
        "move_up",
        "move_down"
    )

    velocity = input_direction * move_speed
    move_and_slide()

var nearby_resources: Array[Node2D] = []


func _on_interaction_area_area_entered(area: Area2D) -> void:
    var resource := area.get_parent()

    if resource != null and resource.has_method("interact"):
        if not nearby_resources.has(resource):
            nearby_resources.append(resource)


func _on_interaction_area_area_exited(area: Area2D) -> void:
    var resource := area.get_parent()
    nearby_resources.erase(resource)


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("interact"):
        _try_interact()


func _try_interact() -> void:
    nearby_resources = nearby_resources.filter(
        func(resource: Node2D) -> bool:
            return is_instance_valid(resource)
    )

    if nearby_resources.is_empty():
        return

    var closest: Node2D = null
    var closest_distance := INF

    for resource in nearby_resources:
        var distance := global_position.distance_squared_to(
            resource.global_position
        )

        if distance < closest_distance:
            closest_distance = distance
            closest = resource

    if closest != null:
        closest.interact()
