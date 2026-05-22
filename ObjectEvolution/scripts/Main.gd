extends Node3D

var player_scene = preload("res://scenes/Player.tscn")
var ui_scene = preload("res://scripts/UIManager.gd")
var level_gen_scene = preload("res://scenes/LevelGenerator.tscn")

var active_player: Node3D
var active_level_gen: Node3D

func _ready():
    print("Main Scene Loaded.")
    GameManager.connect("game_state_changed", Callable(self, "_on_game_state_changed"))
    GameManager.connect("level_started", Callable(self, "_on_level_started"))

    # Wire UI to the CanvasLayer
    var ui_layer = get_node("UI_Layer")
    var ui_manager = ui_scene.new()
    ui_manager.name = "UIManager"
    ui_layer.add_child(ui_manager)

    # Instantiate Level Generator
    active_level_gen = level_gen_scene.instantiate()
    add_child(active_level_gen)

    # Kick off the game immediately for testing
    GameManager.start_level(GameManager.current_level)

func _on_game_state_changed(new_state: String):
    print("Main handling state change to: ", new_state)

func _on_level_started(level_num: int):
    print("Main starting level: ", level_num)
    active_level_gen.generate_level(level_num)

    # Spawn Player
    if active_player == null:
        active_player = player_scene.instantiate()
        active_player.name = "Player"
        add_child(active_player)

        # Connect player health to UI if possible
        active_player.connect("player_died", Callable(self, "_on_player_died"))

    # Reset player position to start
    active_player.position = Vector3(0, 2, 0)
    active_player.health = active_player.max_health
    active_player.current_form = active_player.FormState.NORMAL
    active_player.update_visuals()

func _on_player_died():
    print("Game Over Sequence...")
    # Optional AdManager revive logic could go here
    if has_node("/root/AdManager"):
        get_node("/root/AdManager").show_rewarded_ad("revive")
