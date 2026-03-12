extends Node2D
## 可拾取武器
## - 被玩家捡起后成为玩家武器
## - 可投掷（扔出）

class_name Weapon

@export var weapon_name: String = "Weapon"
@export var attack_power: int = 15
@export var durability: int = -1  # -1 表示耐久无限
@export var throw_force: float = 12.0
@export var is_throwable: bool = true

var owner: Node2D = null  # 被谁拿着
var is_picked_up: bool = false
var velocity: Vector2 = Vector2.ZERO
var gravity_enabled: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var pickup_area: Area2D = $PickupArea
@onready var throw_area: Area2D = $ThrowArea  # 投掷后的伤害区域

func _ready():
	if pickup_area:
		pickup_area.body_entered.connect(_on_body_entered)
	if throw_area:
		throw_area.body_entered.connect(_on_throw_hit)
	print("[Weapon] %s spawned" % weapon_name)

func _physics_process(delta):
	if gravity_enabled and not is_picked_up:
		velocity.y += 980.0 * delta
		position += velocity * delta
		# 简单地面检测
		if global_position.y > 2000:
			queue_free()

func pick_up(new_owner: Node2D):
	owner = new_owner
	is_picked_up = true
	gravity_enabled = false
	velocity = Vector2.ZERO
	# 跟随所有者（简单实现：直接设为子节点）
	get_parent().remove_child(self)
	owner.add_child(self)
	position = Vector2.ZERO  # 相对所有者
	collision_shape.disabled = true
	pickup_area.monitoring = false
	# 显示附着在手上的位置
	sprite.position = Vector2(20, -20)  # 右手

func drop():
	if not is_picked_up:
		return
	get_parent().remove_child(self)
	var current_scene = get_tree().current_scene
	if current_scene:
		current_scene.add_child(self)
		global_position = owner.global_position + Vector2(30, -30)
	is_picked_up = false
	gravity_enabled = true
	collision_shape.disabled = false
	owner = null
	# 投掷初始速度（如果玩家投掷）
	velocity = Vector2(throw_force if owner.facing_right else -throw_force, -5)

func throw(force: Vector2):
	if not is_picked_up:
		return
	drop()
	velocity = force
	gravity_enabled = true
	collision_shape.disabled = false
	# 投掷后短暂开启伤害判定
	if throw_area:
		throw_area.monitoring = true
		await get_tree().create_timer(0.5).timeout
		throw_area.monitoring = false

func _on_body_entered(body: Node2D):
	if is_picked_up:
		return
	# 玩家拾取
	if body is Player:
		body.pick_up_weapon(self)

func _on_throw_hit(body: Node2D):
	if not gravity_enabled:
		return
	if body is Enemy:
		body.take_damage(attack_power, 1 if velocity.x > 0 else -1)
	elif body is BreakableObject:
		body.break_object()
