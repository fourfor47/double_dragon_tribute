extends CharacterBody2D
## 玩家角色脚本
## - 移动：左右、跳跃
## - 攻击：拳、脚、特殊技
## - 血条与死亡
## - 武器拾取与使用

class_name Player

@export var speed: float = 180.0
@export var jump_velocity: float = -400.0
@export var gravity: float = 980.0
@export var max_health: int = 100
@export var attack_power: int = 10
@export var player_index: int = 0  # 0 或 1

var health: int = 100
var is_dead: bool = false
var facing_right: bool = true
var can_attack: bool = true
var attack_cooldown: float = 0.3
var attack_timer: float = 0.0
var is_attacking: bool = false
var current_weapon: Weapon = null

# 动画节点
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hitbox_area: Area2D = $HitboxArea
@onready var health_bar: Control = $HealthBar
@onready var state_label: Label = $StateLabel  # 调试用

# 攻击判定区域
var attack_range_active: bool = false

func _ready():
	health = max_health
	_update_health_bar()
	_setup_hitbox()
	print("[Player%d] Spawned at %s" % [player_index, global_position])

func _physics_process(delta):
	if is_dead:
		return

	# 输入处理
	var dir = InputManager.get_instance().get_move_direction(player_index)
	var jump_pressed = InputManager.get_instance().is_jump_pressed(player_index)
	var attack_pressed = InputManager.get_instance().is_attack_pressed(player_index)

	# 重力
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# 左右移动
	velocity.x = dir * speed
	if dir != 0:
		facing_right = dir > 0
		_update_facing()

	# 跳跃
	if jump_pressed and is_on_floor():
		velocity.y = jump_velocity

	# 攻击
	if attack_pressed and can_attack:
		perform_attack()

	# 攻击计时器
	if not can_attack:
		attack_timer -= delta
		if attack_timer <= 0:
			can_attack = true

	# 移动动画
	_update_animation()

	move_and_slide()

	# 边界检查（掉落死亡）
	if global_position.y > 2000:
		die()

func _update_facing():
	sprite.flip_h = not facing_right
	# 调整碰撞体方向（如果需要）

func _update_animation():
	if is_attacking:
		animation_player.play("attack")
	elif velocity.x != 0:
		animation_player.play("walk")
	else:
		animation_player.play("idle")

func perform_attack():
	if is_attacking:
		return
	is_attacking = true
	can_attack = false
	attack_timer = attack_cooldown
	# 动画驱动攻击判定，这里只触发动画
	# 具体的攻击判定在 _on_attack_frame 中触发

func _setup_hitbox():
	# 设置攻击判定区域
	if hitbox_area:
		hitbox_area.body_entered.connect(_on_attack_hit)
		hitbox_area.monitoring = false

func _on_attack_frame():
	# 动画特定帧调用的函数（在 AnimationPlayer 事件中设置）
	attack_range_active = true
	if hitbox_area:
		hitbox_area.monitoring = true

func _on_attack_end():
	# 攻击动画结束
	attack_range_active = false
	if hitbox_area:
		hitbox_area.monitoring = false
	is_attacking = false

func _on_attack_hit(body: Node2D):
	if attack_range_active:
		if body is Enemy:
			var damage = attack_power
			if current_weapon:
				damage += current_weapon.attack_power
			body.take_damage(damage, facing_right)
		elif body is BreakableObject:
			body.break_object()

func take_damage(amount: int, direction: int):
	if is_dead:
		return
	health -= amount
	_update_health_bar()
	# 击退效果
	velocity.x = 120.0 * (-1 if direction > 0 else 1)
	velocity.y = -200.0
	animation_player.play("hurt")
	if health <= 0:
		die()

func die():
	is_dead = true
	animation_player.play("death")
	# 通知 Game Manager
	var gm = GameManager.get_instance()
	if gm:
		gm.damage_player(player_index, 99999)  # 触发生命减少

func respawn():
	is_dead = false
	health = max_health
	_update_health_bar()
	animation_player.play("idle")
	# 位置将由关卡管理器设置

func _update_health_bar():
	if health_bar:
		var hp = clamp(health, 0, max_health)
		health_bar.value = float(hp) / float(max_health)

func pick_up_weapon(weapon_node: Weapon):
	if current_weapon:
		_drop_current_weapon()
	current_weapon = weapon_node
	weapon_node.pick_up(self)
	# 视觉变化：手持武器
	sprite.modulate = Color(1.2, 1.2, 1.0)  # 微亮表示有武器

func _drop_current_weapon():
	if current_weapon:
		current_weapon.drop()
		current_weapon = null
		sprite.modulate = Color(1, 1, 1)

func _input(event):
	if event.is_action_pressed("pause"):
		gm = GameManager.get_instance()
		if gm:
			gm.toggle_pause()

func _on_animation_finished(anim_name: String):
	if anim_name == "attack":
		_on_attack_end()
	elif anim_name == "death":
		# 隐藏或禁用
		set_physics_process(false)
		sprite.visible = false
