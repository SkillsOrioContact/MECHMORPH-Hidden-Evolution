extends CharacterBody3D

enum EnemyState { IDLE, PATROL, CHASE, ATTACK }
var current_state: EnemyState = EnemyState.PATROL

var speed = 3.0
var detection_radius = 10.0
var attack_radius = 2.0
var damage = 10

var target_player: Node3D = null
var patrol_target: Vector3
var start_pos: Vector3

func _ready():
    start_pos = global_position
    _pick_random_patrol_target()

    # Placeholder Visual for Enemy
    var mesh_instance = MeshInstance3D.new()
    var cyl = CylinderMesh.new()
    cyl.height = 1.5
    cyl.top_radius = 0.5
    cyl.bottom_radius = 0.5
    mesh_instance.mesh = cyl
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(0.2, 0.2, 0.8) # Blue enemy
    cyl.surface_set_material(0, mat)
    add_child(mesh_instance)

    var col = CollisionShape3D.new()
    var shape = CylinderShape3D.new()
    shape.height = 1.5
    shape.radius = 0.5
    col.shape = shape
    add_child(col)

    # Simple Area3D for detection
    var detection_area = Area3D.new()
    var detection_col = CollisionShape3D.new()
    var det_shape = SphereShape3D.new()
    det_shape.radius = detection_radius
    detection_col.shape = det_shape
    detection_area.add_child(detection_col)
    add_child(detection_area)

    detection_area.connect("body_entered", Callable(self, "_on_detection_area_entered"))
    detection_area.connect("body_exited", Callable(self, "_on_detection_area_exited"))

func _physics_process(delta):
    # Gravity
    if not is_on_floor():
        velocity += get_gravity() * delta

    match current_state:
        EnemyState.PATROL:
            _handle_patrol(delta)
        EnemyState.CHASE:
            _handle_chase(delta)
        EnemyState.ATTACK:
            _handle_attack(delta)

    move_and_slide()

func _handle_patrol(delta):
    var dir = (patrol_target - global_position).normalized()
    dir.y = 0
    velocity.x = dir.x * speed
    velocity.z = dir.z * speed

    if global_position.distance_to(patrol_target) < 1.0:
        _pick_random_patrol_target()

    _check_player_detection()

func _handle_chase(delta):
    if not target_player or not _is_player_detectable():
        current_state = EnemyState.PATROL
        return

    var dist = global_position.distance_to(target_player.global_position)
    if dist <= attack_radius:
        current_state = EnemyState.ATTACK
    else:
        var dir = (target_player.global_position - global_position).normalized()
        dir.y = 0
        velocity.x = dir.x * (speed * 1.5)
        velocity.z = dir.z * (speed * 1.5)

func _handle_attack(delta):
    if not target_player or not _is_player_detectable():
        current_state = EnemyState.PATROL
        return

    var dist = global_position.distance_to(target_player.global_position)
    if dist > attack_radius:
        current_state = EnemyState.CHASE
    else:
        velocity.x = 0
        velocity.z = 0
        # Attack Logic (could use a timer)
        print("Enemy attacking player for ", damage, " damage!")
        if target_player.has_method("take_damage"):
            target_player.take_damage(damage)

func _pick_random_patrol_target():
    var rand_offset = Vector3(randf_range(-5, 5), 0, randf_range(-5, 5))
    patrol_target = start_pos + rand_offset

func _is_player_detectable() -> bool:
    if target_player:
        # Player is detectable if they are in COMBAT form AND not currently in Bonus Immortal Mode
        if target_player.current_form == target_player.FormState.COMBAT and not target_player.is_bonus_immortal:
            return true
    return false

func _check_player_detection():
    if target_player and _is_player_detectable():
        current_state = EnemyState.CHASE

func _on_detection_area_entered(body):
    if body.name == "Player":
        target_player = body
        _check_player_detection()

func _on_detection_area_exited(body):
    if body == target_player:
        target_player = null
        if current_state == EnemyState.CHASE or current_state == EnemyState.ATTACK:
            current_state = EnemyState.PATROL
