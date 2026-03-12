extends CharacterBody2D
## 基础敌人AI
## - 巡逻、发现、追击、攻击
## - 简单的状态机

class_name Enemy

enum State {
	PATROL,
	CHASE,
	ATTACK,
	RETURN,
	HURT,
	DEAD
}

@export var health: int = 30
@export var attack_power: int = 5
@export var speed: float = 80.0
@export var detection_range: float = 200.0
@export var attack_range: float = 40.0
@export var patrol_points: Array[Vector2] = []
@export var aggression: float = 0.5  # 攻击频率

var current_state: State = State.PATROL
var target: Player = null
var current_patrol_index: int = 0
var state_timer: float = 0.0
var facing_right: bool = true
var can_attack: bool = true
var attack_cooldown: float = 1.0
var attack_timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hitbox_area: Area2D = $HitboxArea
@onready var detection_area: Area2D = $DetectionArea

signal died(enemy: Enemy)

func _ready():
	_setup_areas()
	if patrol_points.is_empty():
		# 默认在出生点附近巡逻
		push_default_patrol()
	print("[Enemy] Spawned: %s" % name)

func push_default_patrol():
	var p = global_position
	patrol_points = [
		p + Vector2(-100, 0),
		p + Vector2(100, 0),
		p
	]

func _setup_areas():
	if detection_area:
		detection_area.body_entered.connect(_on_player_detected)
	if hitbox_area:
		hitbox_area.body_entered.connect(_on_attack_hit)

func _physics_process(delta):
	match current_state:
		State.PATROL:
			_do_patrol(delta)
		State.CHASE:
			_do_chase(delta)
		State.ATTACK:
			_do_attack(delta)
		State.RETURN:
			_do_return(delta)
		State.HURT:
			# 受伤不移动
			pass
		State.DEAD:
			return

	# 击退移动（如被攻击）
	if velocity.x != 0:
		move_and_slide()

	# 攻击计时器
	if not can_attack:
		attack_timer -= delta
		if attack_timer <= 0:
			can_attack = true

func _do_patrol(delta):
	if patrol_points.is_empty():
		return
	var point = patrol_points[current_patrol_index]
	var dir = (point - global_position).normalized()
	if global_position.distance_to(point) < 10:
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
	else:
		velocity = dir * speed * delta
		move_and_slide()
		_update_facing(velocity.x)
		animation_player.play("walk" if velocity.x != 0 else "idle")

func _do_chase(delta):
	if not target or target.is_dead:
		current_state = State.PATROL
		return
	var dir = (target.global_position - global_position).normalized()
	velocity = dir * speed * delta
	move_and_slide()
	_update_facing(velocity.x)
	animation_player.play("run")
	var dist = global_position.distance_to(target.global_position)
	if dist <= attack_range and can_attack:
		current_state = State.ATTACK

func _do_attack(delta):
	if not target or target.is_dead:
		current_state = State.PATROL
		return
	velocity = Vector2.ZERO
	animation_player.play("attack")
	# 攻击判定在动画帧事件触发
	# 冷却
	can_attack = false
	attack_timer = attack_cooldown + randf_range(-0.2, 0.2) * aggression
	# 一段时间后继续追击
	state_timer += delta
	if state_timer > 0.5:
		state_timer = 0.0
		current_state = State.CHASE

func _do_return(delta):
	# 返回巡逻点或原位置
	if global_position.distance_to(patrol_points[0]) < 10:
		current_state = State.PATROL
	else:
		var dir = (patrol_points[0] - global_position).normalized()
		velocity = dir * speed * delta
		move_and_slide()
		_update_facing(velocity.x)

func _update_facing(vx: float):
	if vx > 0.1:
		facing_right = true
		sprite.flip_h = false
	elif vx < -0.1:
		facing_right = false
		sprite.flip_h = true

func _on_player_detected(body: Node2D):
	if body is Player and current_state != State.DEAD:
		target = body
		current_state = State.CHASE

func _on_attack_hit(body: Node2D):
	if current_state != State.ATTACK:
		return
	if body is Player:
		body.take_damage(attack_power, facing_right)

func take_damage(amount: int, direction: int):
	if current_state == State.DEAD:
		return
	health -= amount
	current_state = State.HURT
	animation_player.play("hurt")
	# 击退
	velocity.x = 80.0 * (-1 if direction > 0 else 1)
	velocity.y = -150.0
	move_and_slide()
	# 短暂无敌时间
	await get_tree().create_timer(0.3).timeout
	if health <= 0:
		die()
	else:
		# 返回之前状态（如果还有目标）
		if target and not target.is_dead:
			current_state = State.CHASE
		else:
			current_state = State.PATROL

func die():
	current_state = State.DEAD
	animation_player.play("death")
	died.emit(self)
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _on_animation_finished(anim_name: String):
	if anim_name == "attack":
		# 攻击动画结束，保持攻击状态一瞬然后回到追击
		await get_tree().create_timer(0.1).timeout
		if current_state == State.ATTACK:
			current_state = State.CHASE

func _draw():
	# 调试用：绘制检测范围
	#if current_state == State.CHASE:
	#	draw_circle(Vector2.ZERO, detection_range, Color(1, 0, 0, 0.2))
	pass
