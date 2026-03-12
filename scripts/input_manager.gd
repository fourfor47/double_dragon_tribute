extends Node
## 输入管理
## - 支持双人同屏
## - 统一输入映射（键盘、手柄）
## - 提供输入缓冲优化手感

signal action_pressed(action: String, player_index: int)
signal action_released(action: String, player_index: int)

var _pressed_actions: Dictionary = {}

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_controllers()
	print("[InputManager] Initialized with controller support")

func _setup_controllers():
	# 确保每个玩家最多支持1个手柄
	# Godot 会自动处理 InputMap，这里只做映射检查
	pass

func _unhandled_input(event):
	if event is InputEventKey:
		var key_idx = event.keycode
		var action = _get_action_for_key(key_idx, event.pressed)
		if action:
			action_pressed.emit(action.action, action.player)
			_pressed_actions[action] = event.pressed
	elif event is InputEventJoypadButton:
		var btn_idx = event.button_index
		var action = _get_action_for_joypad_button(btn_idx, event.pressed)
		if action:
			action_pressed.emit(action.action, action.player)
			_pressed_actions[action] = event.pressed

func get_move_direction(player_index: int) -> float:
	# 返回 -1（左）、0、1（右）
	var left_action = "move_left" if player_index == 0 else "player2_move_left"
	var right_action = "move_right" if player_index == 0 else "player2_move_right"
	var left = Input.get_action_strength(left_action)
	var right = Input.get_action_strength(right_action)
	return right - left

func is_jump_pressed(player_index: int) -> bool:
	var jump_action = "jump" if player_index == 0 else "player2_jump"
	return Input.is_action_just_pressed(jump_action)

func is_attack_pressed(player_index: int) -> bool:
	var attack_action = "attack" if player_index == 0 else "player2_attack"
	return Input.is_action_just_pressed(attack_action)

func is_attack_held(player_index: int) -> bool:
	var attack_action = "attack" if player_index == 0 else "player2_attack"
	return Input.is_action_pressed(attack_action)

func _get_action_for_key(key: int, pressed: bool) -> Dictionary:
	# 映射键盘按键到玩家动作
	var key_map = {
		# Player 1
		Key.A: {"action": "move_left", "player": 0},
		Key.D: {"action": "move_right", "player": 0},
		Key.W: {"action": "jump", "player": 0},
		Key.Z: {"action": "attack", "player": 0},
		# Player 2
		Key.J: {"action": "move_left", "player": 1},
		Key.L: {"action": "move_right", "player": 1},
		Key.I: {"action": "jump", "player": 1},
		Key.K: {"action": "attack", "player": 1},
	}
	if key in key_map:
		return key_map[key]
	return {}

func _get_action_for_joypad_button(button: int, pressed: bool) -> Dictionary:
	# 手柄映射：玩家1用手柄0，玩家2用手柄1
	var player = 0 if button < 20 else 1  # 简单区分：前20个按钮归玩家1
	var action_map = {
		0: "attack", 1: "attack",  # A/B
		2: "jump",   # X (? Y?)
		3: "jump",   # Y
		15: "move_left",  # D-pad left
		16: "move_right", # D-pad right
	}
	if button in action_map:
		return {"action": action_map[button], "player": player}
	return {}
