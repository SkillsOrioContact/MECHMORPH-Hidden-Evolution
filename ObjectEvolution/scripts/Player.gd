extends CharacterBody3D

const SPEED_NORMAL = 5.0
const SPEED_COMBAT = 10.0
const ACCELERATION = 10.0
const JUMP_VELOCITY = 4.5

# Dual-State System
enum FormState { NORMAL, COMBAT }
var current_form: FormState = FormState.NORMAL

# Bonus State
var is_bonus_immortal: bool = false
var bonus_timer: float = 0.0

# Health
var health: int = 100
var max_health: int = 100

# References to visuals (will be added via code or packed scene)
var normal_visual: Node3D
var combat_visual: Node3D

signal state_changed(new_state)
signal bonus_immortal_started
signal bonus_immortal_ended
signal health_changed(new_health)
signal player_died

func _ready():
    # Setup placeholder visuals dynamically
    normal_visual = MeshInstance3D.new()
    var box = BoxMesh.new()
    box.size = Vector3(1, 1, 1)
    normal_visual.mesh = box
    var normal_mat = StandardMaterial3D.new()
    normal_mat.albedo_color = Color(0.5, 0.5, 0.5) # Grey for stealth
    box.surface_set_material(0, normal_mat)
    add_child(normal_visual)

    combat_visual = MeshInstance3D.new()
    var sphere = SphereMesh.new()
    sphere.radius = 0.6
    sphere.height = 1.2
    combat_visual.mesh = sphere
    var combat_mat = StandardMaterial3D.new()
    combat_mat.albedo_color = Color(1.0, 0.0, 0.0) # Red for combat
    sphere.surface_set_material(0, combat_mat)
    add_child(combat_visual)

    # Setup Collision
    var collision_shape = CollisionShape3D.new()
    var shape = BoxShape3D.new()
    shape.size = Vector3(1, 1, 1)
    collision_shape.shape = shape
    add_child(collision_shape)

    # Instantiate TransformationManager dynamically instead of isolated node
    if not has_node("TransformationManager"):
        var tm = preload("res://scripts/TransformationManager.gd").new()
        tm.name = "TransformationManager"
        add_child(tm)

    update_visuals()

func _physics_process(delta):
    # Handle Bonus Timer
    if is_bonus_immortal:
        bonus_timer -= delta
        if bonus_timer <= 0:
            end_bonus_immortal()

    # Add gravity
    if not is_on_floor():
        velocity += get_gravity() * delta

    # Handle Jump
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    # Get input direction
    var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

    var current_speed = SPEED_NORMAL if current_form == FormState.NORMAL else SPEED_COMBAT

    if direction:
        velocity.x = move_toward(velocity.x, direction.x * current_speed, ACCELERATION * delta)
        velocity.z = move_toward(velocity.z, direction.z * current_speed, ACCELERATION * delta)
    else:
        velocity.x = move_toward(velocity.x, 0, ACCELERATION * delta)
        velocity.z = move_toward(velocity.z, 0, ACCELERATION * delta)

    move_and_slide()

func toggle_form():
    var tm = get_node_or_null("TransformationManager")
    if tm and tm.is_transforming:
        return # Block input while transforming

    var target_form = FormState.COMBAT if current_form == FormState.NORMAL else FormState.NORMAL

    if tm:
        tm.perform_transformation(self, target_form)
    else:
        # Fallback instant swap
        current_form = target_form
        update_visuals()
        emit_signal("state_changed", current_form)

func update_visuals():
    normal_visual.visible = (current_form == FormState.NORMAL)
    combat_visual.visible = (current_form == FormState.COMBAT)

func start_bonus_immortal(duration: float = 30.0):
    is_bonus_immortal = true
    bonus_timer = duration
    emit_signal("bonus_immortal_started")
    print("Bonus Immortal Mode Started for ", duration, " seconds!")

func end_bonus_immortal():
    is_bonus_immortal = false
    bonus_timer = 0.0
    emit_signal("bonus_immortal_ended")
    print("Bonus Immortal Mode Ended.")

func collect_energy_shard(amount: int):
    # Only collect in combat form OR if bonus immortal
    if current_form == FormState.COMBAT or is_bonus_immortal:
        if GameManager:
            GameManager.add_energy_shards(amount)
            # Example logic for triggering bonus
            if GameManager.total_energy_shards % 50 == 0:
                start_bonus_immortal(30.0)
        return true
    return false

func take_damage(amount: int):
    if is_bonus_immortal:
        print("Player is immortal! No damage taken.")
        return

    if current_form == FormState.NORMAL:
        # Immune to enemies, but maybe hazards? Prompt says "no damage from fire/lasers/traps" in normal form.
        print("Player is in Normal Form! Immune to damage.")
        return

    # Apply damage logic here for combat form
    health -= amount
    emit_signal("health_changed", health)
    print("Player took ", amount, " damage! Health: ", health)

    if health <= 0:
        emit_signal("player_died")
        print("Player died!")
