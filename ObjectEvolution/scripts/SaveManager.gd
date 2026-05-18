extends Node

const SAVE_FILE = "user://savegame.json"

var game_data = {
    "current_level": 1,
    "total_energy_shards": 0,
    "unlocked_objects": ["coin", "pen", "flashlight"],
    "evolution_states": {
        "coin": 0,
        "pen": 0,
        "flashlight": 0
    }
}

func _ready():
    load_game()

func save_game():
    # Sync from GameManager
    if has_node("/root/GameManager"):
        var gm = get_node("/root/GameManager")
        game_data["current_level"] = gm.current_level
        game_data["total_energy_shards"] = gm.total_energy_shards

    var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(game_data))
        file.close()
        print("Game saved successfully.")
    else:
        print("Failed to save game.")

func load_game():
    if FileAccess.file_exists(SAVE_FILE):
        var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
        if file:
            var content = file.get_as_text()
            file.close()
            var json = JSON.new()
            var error = json.parse(content)
            if error == OK:
                if typeof(json.data) == TYPE_DICTIONARY:
                    game_data = json.data
                    print("Game loaded successfully.")
                    return
    print("No save file found or parse error. Using default data.")
