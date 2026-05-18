extends Node

# Handles the 5-step procedural transformation animation

# 1. Energy Awakening (glow + vibration)
# 2. Structural Breakdown (object splits)
# 3. Mechanical Reconstruction (assembly)
# 4. Core Activation (power ignition)
# 5. Stabilization (idle mode)

signal transformation_finished

var is_transforming = false

func perform_transformation(player: Node3D, target_form: int):
    if is_transforming:
        return

    is_transforming = true
    print("Starting Transformation Sequence...")

    # We will use Godot's Tween system to animate the 5-step sequence
    var tween = get_tree().create_tween()

    var current_visual = player.normal_visual if target_form == 1 else player.combat_visual
    var next_visual = player.combat_visual if target_form == 1 else player.normal_visual

    # 1. Energy Awakening: Vibration and Glow
    # Vibrate by slightly offsetting position rapidly
    var original_pos = current_visual.position
    for i in range(10):
        var random_offset = Vector3(randf_range(-0.1, 0.1), 0, randf_range(-0.1, 0.1))
        tween.tween_property(current_visual, "position", original_pos + random_offset, 0.05)
    tween.tween_property(current_visual, "position", original_pos, 0.05)

    # 2. Structural Breakdown: Scale up slightly and disappear
    tween.tween_property(current_visual, "scale", Vector3(1.2, 1.2, 1.2), 0.2)
    tween.tween_callback(Callable(self, "_swap_visuals").bind(player, target_form))

    # 3. Mechanical Reconstruction: Target object scales in
    # (next_visual is now active because of _swap_visuals callback)
    next_visual.scale = Vector3(0.1, 0.1, 0.1)
    tween.tween_property(next_visual, "scale", Vector3(1.2, 1.2, 1.2), 0.3).set_trans(Tween.TRANS_BOUNCE)

    # 4. Core Activation: Quick pulse
    tween.tween_property(next_visual, "scale", Vector3(0.9, 0.9, 0.9), 0.1)
    tween.tween_property(next_visual, "scale", Vector3(1.1, 1.1, 1.1), 0.1)

    # 5. Stabilization
    tween.tween_property(next_visual, "scale", Vector3(1.0, 1.0, 1.0), 0.2)

    tween.tween_callback(Callable(self, "_on_transformation_complete"))

func _swap_visuals(player: Node3D, target_form: int):
    print("Step 2/3: Structural Breakdown -> Mechanical Reconstruction")
    player.current_form = target_form
    player.update_visuals()

func _on_transformation_complete():
    print("Step 5: Stabilization Complete.")
    is_transforming = false
    emit_signal("transformation_finished")
