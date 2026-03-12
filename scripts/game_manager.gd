extends Node
## 全局游戏管理器
## - 管理玩家状态
## - 关卡进度
## - 游戏暂停
## - 得分与生命

signal game_paused
signal game_resumed
signal player_died(player_index: int)
signal stage_completed(stage_id: int)
signal game_over

var current_stage_id: int = 1
var player_health: Array = [100, 100]
var player_lives: Array = [3, 3]
var is_paused: bool = false
var game_over_flag: bool = false

# 单例访问
static func get_instance() -> Node:
	return Engine.get_singleton("GameManager") as GameManager

func _ready():
	# 确保这个节点在场景树中作为自动加载存在
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("[GameManager] Initialized")

func get_player_health(index: int) -> int:
	if index >= 0 and index < player_health.size():
		return player_health[index]
	return 0

func damage_player(index: int, amount: int):
	if index >= 0 and index < player_health.size():
		player_health[index] -= amount
		if player_health[index] <= 0:
			player_lives[index] -= 1
			if player_lives[index] <= 0:
				# 检查是否所有玩家都死了
				if player_lives[0] <= 0 and player_lives[1] <= 0:
					game_over_flag = true
					game_over.emit()
			else:
				player_died.emit(index)
				# TODO: 复活机制（从当前关开始或检查点）
				respawn_player(index)

func respawn_player(index: int):
	player_health[index] = 100
	# 通知关卡管理器重生玩家
	var current_scene = get_tree().current_scene
	if current_scene and current_scene.has_method("respawn_player"):
		current_scene.respawn_player(index)

func pause_game():
	if not is_paused:
		is_paused = true
		get_tree().paused = true
		game_paused.emit()

func resume_game():
	if is_paused:
		is_paused = false
		get_tree().paused = false
		game_resumed.emit()

func toggle_pause():
	if is_paused:
		resume_game()
	else:
		pause_game()

func complete_stage():
	stage_completed.emit(current_stage_id)
	current_stage_id += 1
	# TODO: 加载下一关或显示结局

func reset_game():
	player_health = [100, 100]
	player_lives = [3, 3]
	current_stage_id = 1
	game_over_flag = false
