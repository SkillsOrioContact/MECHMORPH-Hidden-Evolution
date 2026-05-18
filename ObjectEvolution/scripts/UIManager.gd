extends Control

@onready var game_manager = get_node("/root/GameManager")

# UI Elements
var toggle_btn: Button
var health_bar: ProgressBar
var energy_label: Label
var bonus_timer_label: Label

func _ready():
    # Build In-Game UI
    set_anchors_preset(Control.PRESET_FULL_RECT)
    var hud_container = MarginContainer.new()
    hud_container.set_anchors_preset(Control.PRESET_FULL_RECT)
    hud_container.add_theme_constant_override("margin_top", 50)
    hud_container.add_theme_constant_override("margin_left", 50)
    hud_container.add_theme_constant_override("margin_right", 50)
    hud_container.add_theme_constant_override("margin_bottom", 50)
    add_child(hud_container)

    var top_bar = HBoxContainer.new()
    hud_container.add_child(top_bar)

    energy_label = Label.new()
    energy_label.text = "Energy: 0"
    energy_label.add_theme_font_size_override("font_size", 32)
    top_bar.add_child(energy_label)

    var spacer = Control.new()
    spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    top_bar.add_child(spacer)

    bonus_timer_label = Label.new()
    bonus_timer_label.text = ""
    bonus_timer_label.add_theme_font_size_override("font_size", 32)
    bonus_timer_label.add_theme_color_override("font_color", Color(1, 1, 0)) # Yellow
    top_bar.add_child(bonus_timer_label)

    var bottom_bar = VBoxContainer.new()
    bottom_bar.size_flags_vertical = Control.SIZE_SHRINK_END
    hud_container.add_child(bottom_bar)

    health_bar = ProgressBar.new()
    health_bar.custom_minimum_size = Vector2(300, 30)
    health_bar.value = 100
    bottom_bar.add_child(health_bar)

    toggle_btn = Button.new()
    toggle_btn.text = "TRANSFORM"
    toggle_btn.custom_minimum_size = Vector2(400, 100)
    toggle_btn.add_theme_font_size_override("font_size", 48)
    toggle_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    bottom_bar.add_child(toggle_btn)

    toggle_btn.connect("pressed", Callable(self, "_on_toggle_pressed"))

func _process(delta):
    if game_manager:
        energy_label.text = "Energy: " + str(game_manager.total_energy_shards)

    # Assume we find player dynamically from root
    var main_scene = get_node("/root/Main")
    if main_scene and main_scene.has_node("Player"):
        var player = main_scene.get_node("Player")

        # Update health bar
        health_bar.max_value = player.max_health
        health_bar.value = player.health

        if player.is_bonus_immortal:
            bonus_timer_label.text = "IMMORTAL: " + str(int(player.bonus_timer)) + "s"
        else:
            bonus_timer_label.text = ""

func _on_toggle_pressed():
    print("UI Transform Button Pressed!")
    var main_scene = get_node("/root/Main")
    if main_scene and main_scene.has_node("Player"):
        main_scene.get_node("Player").toggle_form()
