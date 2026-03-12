extends CanvasLayer
## 游戏 HUD
## - 显示玩家血条
## - 显示关卡时间
## - 暂停界面

@onready var p1_bar: TextureProgressBar = $Player1Health
@onready var p2_bar: TextureProgressBar = $Player2Health
@onready var timer_label: Label = $Timer
@onready var pause_overlay: Panel = $PauseOverlay

var time_remaining: int = 99

func _ready():
	# 连接到 GameManager
	var gm = GameManager.get_instance()
	if gm:
		gm.game_paused.connect(_on_game_paused)
		gm.game_resumed.connect(_on_game_resumed)
		gm.stage_completed.connect(_on_stage_completed)

	# 关卡计时器初始化
	time_remaining = 99
	_update_timer()
	_start_timer()

func _start_timer():
	await get_tree().create_timer(1.0).timeout
	_update_timer()

func _update_timer():
	timer_label.text = "%d" % time_remaining

func _on_game_paused():
	pause_overlay.visible = true

func _on_game_resumed():
	pause_overlay.visible = false

func _on_stage_completed(stage_id: int):
	# 显示过关信息
	timer_label.text = "关卡完成!"

func update_player_health(player_index: int, health: int, max_health: int):
	var bar = p1_bar if player_index == 0 else p2_bar
	if bar:
		bar.value = float(health) / float(max_health)

func _process(delta):
	if Engine.get_physics_frames() % 60 == 0:  # 每秒更新一次
		if not pause_overlay.visible:
			time_remaining -= 1
			_update_timer()
			if time_remaining <= 0:
				# 时间到，玩家死亡
				var gm = GameManager.get_instance()
				if gm:
					gm.damage_player(0, 99999)
					gm.damage_player(1, 99999)
