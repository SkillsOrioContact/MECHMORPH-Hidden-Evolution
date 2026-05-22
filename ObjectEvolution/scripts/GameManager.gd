extends Node

# State constants
const STATE_MAIN_MENU = "MAIN_MENU"
const STATE_IN_GAME = "IN_GAME"
const STATE_EVOLUTION_TREE = "EVOLUTION_TREE"

var current_state: String = STATE_MAIN_MENU

# Progression
var current_level: int = 1
var max_level: int = 200

# Active Player State
var current_object_id: String = "coin"
var current_evolution_stage: int = 0
var total_energy_shards: int = 0

signal game_state_changed(new_state)
signal level_started(level_num)
signal level_completed(level_num)

func _ready():
    print("GameManager initialized.")

func change_state(new_state: String):
    current_state = new_state
    emit_signal("game_state_changed", current_state)

func start_level(level_num: int):
    current_level = clamp(level_num, 1, max_level)
    change_state(STATE_IN_GAME)
    emit_signal("level_started", current_level)

func complete_current_level():
    emit_signal("level_completed", current_level)
    if current_level < max_level:
        current_level += 1
    # Trigger auto save via SaveManager
    if has_node("/root/SaveManager"):
        get_node("/root/SaveManager").save_game()

func add_energy_shards(amount: int):
    total_energy_shards += amount
    print("Total Shards: ", total_energy_shards)
