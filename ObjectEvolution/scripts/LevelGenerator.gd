extends Node3D

# Procedural Level Generator
# Handles generating environments, enemies, and obstacles based on level tier

var current_tier: int = 1
var tile_size: float = 4.0
var level_grid_size: Vector2 = Vector2(10, 10)

var enemy_scene = preload("res://scenes/EnemyBase.tscn")
# Placeholder for collectible Shard
# var shard_scene = preload("res://scenes/EnergyShard.tscn")

func _ready():
    print("LevelGenerator Ready.")

func generate_level(level_number: int):
    # Clear existing children
    for child in get_children():
        child.queue_free()

    current_tier = ((level_number - 1) / 20) + 1
    print("Generating Level: ", level_number, " | Tier: ", current_tier)

    # Scale difficulty based on level
    level_grid_size = Vector2(10 + (level_number * 0.1), 10 + (level_number * 0.1))
    var num_enemies = 1 + int(level_number * 0.1)
    var num_obstacles = 5 + int(level_number * 0.2)
    var num_shards = 5 + int(level_number * 0.05)

    _build_floor()
    _spawn_obstacles(num_obstacles)
    _spawn_enemies(num_enemies)
    _spawn_shards(num_shards)

func _build_floor():
    var floor_mesh = MeshInstance3D.new()
    var plane = PlaneMesh.new()
    plane.size = Vector2(level_grid_size.x * tile_size, level_grid_size.y * tile_size)
    floor_mesh.mesh = plane

    var mat = StandardMaterial3D.new()
    # Change floor color based on Tier
    if current_tier == 1: mat.albedo_color = Color(0.3, 0.4, 0.3) # Forest/Scrap
    elif current_tier == 2: mat.albedo_color = Color(0.4, 0.3, 0.3) # Combat Arena
    elif current_tier == 3: mat.albedo_color = Color(0.3, 0.3, 0.5) # Sky Fortress
    else: mat.albedo_color = Color(0.2, 0.2, 0.2) # Darker for higher tiers

    plane.surface_set_material(0, mat)
    add_child(floor_mesh)

    var static_body = StaticBody3D.new()
    var col_shape = CollisionShape3D.new()
    var shape = BoxShape3D.new()
    shape.size = Vector3(plane.size.x, 0.1, plane.size.y)
    col_shape.shape = shape
    static_body.add_child(col_shape)
    floor_mesh.add_child(static_body)

func _spawn_obstacles(count: int):
    for i in range(count):
        var obs = MeshInstance3D.new()
        var box = BoxMesh.new()
        box.size = Vector3(randf_range(1, 3), randf_range(2, 5), randf_range(1, 3))
        obs.mesh = box

        var mat = StandardMaterial3D.new()
        mat.albedo_color = Color(0.5, 0.5, 0.5)
        box.surface_set_material(0, mat)

        var pos_x = randf_range(-level_grid_size.x * tile_size / 2.2, level_grid_size.x * tile_size / 2.2)
        var pos_z = randf_range(-level_grid_size.y * tile_size / 2.2, level_grid_size.y * tile_size / 2.2)
        obs.position = Vector3(pos_x, box.size.y / 2, pos_z)

        var sb = StaticBody3D.new()
        var cs = CollisionShape3D.new()
        var shape = BoxShape3D.new()
        shape.size = box.size
        cs.shape = shape
        sb.add_child(cs)
        obs.add_child(sb)

        add_child(obs)

func _spawn_enemies(count: int):
    for i in range(count):
        if enemy_scene:
            var enemy = enemy_scene.instantiate()
            var pos_x = randf_range(-level_grid_size.x * tile_size / 2.5, level_grid_size.x * tile_size / 2.5)
            var pos_z = randf_range(-level_grid_size.y * tile_size / 2.5, level_grid_size.y * tile_size / 2.5)
            enemy.position = Vector3(pos_x, 1.0, pos_z)

            # Boost stats for higher tiers
            enemy.damage += current_tier * 2
            enemy.speed += current_tier * 0.2

            add_child(enemy)

func _spawn_shards(count: int):
    for i in range(count):
        var shard = Area3D.new()

        var mesh_inst = MeshInstance3D.new()
        var prim = PrismMesh.new()
        prim.size = Vector3(0.5, 0.8, 0.5)
        mesh_inst.mesh = prim
        var mat = StandardMaterial3D.new()
        mat.albedo_color = Color(0.0, 1.0, 1.0)
        mat.emission_enabled = true
        mat.emission = Color(0.0, 1.0, 1.0)
        prim.surface_set_material(0, mat)
        shard.add_child(mesh_inst)

        var col = CollisionShape3D.new()
        var shape = SphereShape3D.new()
        shape.radius = 0.6
        col.shape = shape
        shard.add_child(col)

        var pos_x = randf_range(-level_grid_size.x * tile_size / 2.2, level_grid_size.x * tile_size / 2.2)
        var pos_z = randf_range(-level_grid_size.y * tile_size / 2.2, level_grid_size.y * tile_size / 2.2)
        shard.position = Vector3(pos_x, 0.5, pos_z)

        shard.connect("body_entered", Callable(self, "_on_shard_collected").bind(shard))
        add_child(shard)

func _on_shard_collected(body, shard_node):
    if body.name == "Player":
        if body.collect_energy_shard(10):
            print("Energy shard collected!")
            shard_node.queue_free()
        else:
            # Player might be in Normal Form without Bonus
            print("Must be in Combat Form to collect shards!")
