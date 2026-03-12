extends Node2D
## 关卡管理器
## - 加载 Tiled 地图
## - 生成玩家和敌人
## - 摄像机管理
## - 关卡完成条件

@export var stage_id: int = 1
@export var stage_map: PackedScene  # 预构建的地图场景
@export var player_scene: PackedScene
@export var enemy_scenes: Array[PackedScene] = []
@export var weapon_scenes: Array[PackedScene] = []
@export var player_spawn_points: Array[Vector2] = [Vector2(100, 100), Vector2(150, 100)]
@export var enemy_spawn_points: Array[Vector2] = []
@export var weapon_spawn_points: Array[Dictionary] = []  # {position: Vector2, type: int}

var players: Array[Player] = []
var enemies: Array[Enemy] = []

@onready var camera: Camera2D = $Camera2D
@onready var tilemap: TileMap = $TileMap  # 假设使用 TileMap

func _ready():
	print("[StageLoader] Stage %d loading" % stage_id)
	_spawn_players()
	_spawn_enemies()
	_spawn_weapons()
	_setup_camera()
	_connect_signals()

func _spawn_players():
	for i in 2:  # 最多2名玩家
		var spawn_pos = player_spawn_points[i] if i < player_spawn_points.size() else Vector2(200, 200)
		if player_scene:
			var player = player_scene.instantiate()
			player.player_index = i
			player.global_position = spawn_pos
			add_child(player)
			players.append(player)
			print("[Stage] Spawned Player %d at %s" % [i, spawn_pos])

func _spawn_enemies():
	if enemy_scenes.is_empty():
		return
	for idx, point in enumerate(enemy_spawn_points):
		if idx >= enemy_scenes.size():
			break
		var enemy_scene = enemy_scenes[idx % enemy_scenes.size()]
		var enemy = enemy_scene.instantiate()
		enemy.global_position = point
		add_child(enemy)
		enemies.append(enemy)
		print("[Stage] Spawned Enemy at %s" % point)

func _spawn_weapons():
	if weapon_scenes.is_empty() or weapon_spawn_points.is_empty():
		return
	for wp in weapon_spawn_points:
		var type_idx = wp.get("type", 0) % weapon_scenes.size()
		var weapon_scene = weapon_scenes[type_idx]
		var weapon = weapon_scene.instantiate()
		weapon.global_position = wp.position
		add_child(weapon)
		print("[Stage] Spawned Weapon at %s" % wp.position)

func _setup_camera():
	if camera:
		# 双人模式下调整摄像机边界
		if players.size() == 2:
			var min_x = min(players[0].global_position.x, players[1].global_position.x)
			var max_x = max(players[0].global_position.x, players[1].global_position.x)
			var viewport_width = 1280 / 2  # 假设缩放为1
			camera.limit_left = min(min_x - 400, tilemap.get_used_rect().position.x)
			camera.limit_right = max(max_x + 400, tilemap.get_used_rect().end.x)
			camera.limit_top = tilemap.get_used_rect().position.y - 200
			camera.limit_bottom = tilemap.get_used_rect().end.y + 200
		else:
			camera.limit_left = tilemap.get_used_rect().position.x
			camera.limit_right = tilemap.get_used_rect().end.x
			camera.limit_top = tilemap.get_used_rect().position.y
			camera.limit_bottom = tilemap.get_used_rect().end.y
		camera.reset_smoothing()

func _connect_signals():
	var gm = GameManager.get_instance()
	if gm:
		gm.player_died.connect(_on_player_died)
		gm.stage_completed.connect(_on_stage_completed)

func _on_player_died(player_index: int):
	if player_index < players.size():
		players[player_index].respawn()

func _on_stage_completed(stage_id: int):
	if stage_id == self.stage_id:
		# 显示过关画面
		print("[Stage] Stage %d completed!" % stage_id)
		# TODO: 加载下一关

func respawn_player(player_index: int):
	if player_index < players.size():
		var spawn_point = player_spawn_points[player_index] if player_spawn_points.size() > player_index else Vector2(200, 200)
		players[player_index].global_position = spawn_point
		players[player_index].respawn()
		# 暂时无敌
		yield(get_tree().create_timer(2.0), "timeout")
		players[player_index].is_dead = false
		players[player_index].set_physics_process(true)
		players[player_index].sprite.visible = true

func check_stage_clear() -> bool:
	# 检查所有敌人是否死亡
	if enemies.is_empty():
		return true
	for e in enemies:
		if is_instance_valid(e) and not e.is_dead:
			return false
	return true

func _process(delta):
	# 定期检查关卡是否通过
	if not enemies.is_empty() and check_stage_clear():
		var gm = GameManager.get_instance()
		if gm:
			gm.complete_stage()
