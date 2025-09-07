extends CharacterBody2D

@onready var animation: AnimatedSprite2D = $Grapsics/Animation
@onready var hand_checker: RayCast2D = $Grapsics/HandChecker
@onready var foot_checker: RayCast2D = $Grapsics/FootChecker
@onready var grapsics: Node2D = $Grapsics

## 物理常数
const GRAVITY := 900.0 # 普通重力加速度
const FAST_FALL_GRAVITY := 2000.0 # 快速下落时的重力加速度
const MAX_FALL := 160.0 # 最大下落速度（普通）
const FAST_MAX_FALL := 240.0 # 最大下落速度（快速下落）
# 奔跑相关
const MAX_RUN := 90.0 # 最大奔跑速度
const HOLDING_MAX_RUN := 70.0 # 抱物时最大奔跑速度
const RUN_ACCEL := 1000.0 # 加速度
const RUN_REDUCE := 400.0 # 摩擦/减速率
const AIR_MULT := 0.65 # 空中加速倍率
# 跳跃相关
const JUMP_SPEED := 105.0 * 2.5 # 跳跃初速度
const VAR_JUMP_TIME := 0.20 # 可变跳窗口
const JUMP_COYOTE_TIME := 0.10 # 落地后宽容时间
const JUMP_BUFFER_TIME := 0.10 # 提前按键缓冲
# 攀爬相关
const CLIMB_MAX_STAMINA: float = 110.0 # 最大体力值
const CLIMB_UP_SPEED: float = 45.0 # 向上攀爬速度（像素/秒）
const CLIMB_DOWN_SPEED: float = 80.0 # 向下攀爬速度（像素/秒）
const CLIMB_SLIP_SPEED: float = 30.0 # 体力耗尽时的滑落速度
const CLIMB_ACCEL: float = 900.0 # 攀爬加速度，让速度逐渐逼近目标值
const WALL_JUMP_FORCE: Vector2 = Vector2(120, 105) # 攀爬跳的水平与垂直初速度、

## 变量
# var velocity: Vector2 # CharacterBody2D的隐藏变量
var holding := false # 是否正在抱物体
var move_input := Input.get_action_strength("right") - Input.get_action_strength("left") # 读取左右输入（1：右，-1：左）
var on_ground := is_on_floor() # 当前是否在地面
var can_move := true # 是否可以移动
var can_apply_gravity := true # 是否可以应用重力
# 跳跃相关
var can_jump := true
var is_jumping := false # 是否正在跳跃
var var_jump_timer := 0.0 # 可变跳定时器
var coyote_timer := 0.0 # Coyote Time
var buffer_timer := 0.0 # 提前按跳缓冲
# 攀爬相关
var is_walling := false # 是否正在墙上
var stamina := CLIMB_MAX_STAMINA # 当前体力
var on_wall := false # 是否在贴墙
# var wall_dir := 0 # 贴哪一边的墙：-1：左墙，1：右墙

func _physics_process(delta: float) -> void:
	# 更新变量
	move_input = Input.get_action_strength("right") - Input.get_action_strength("left")
	on_ground = is_on_floor()

	# 更新 Coyote Time
	if on_ground:
		coyote_timer = JUMP_COYOTE_TIME
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)

	# 是否可以移动
	if can_move == true:
		apply_horizontal_move(delta) # 水平移动

	# 是否应用重力
	if can_apply_gravity == true:
		apply_gravity(delta) # 重力
	
	direction_reversal() # 方向反转
	handle_jump_input(delta) # 跳跃

	# 攀爬
	check_wall_contact() # 检查是否贴着墙，并更新方向

	move_and_slide() # 移动角色


# 素材反转
func direction_reversal() -> void:
	if move_input != 0.0:
		grapsics.scale.x = move_input
		

# 重力
func apply_gravity(delta: float) -> void:
	# 是否按下“向下键” → 快速下落
	var fast_fall := Input.is_action_pressed("down")

	if fast_fall == true:
		# 快速下落：使用更强的重力
		velocity.y += FAST_FALL_GRAVITY * delta
		# 限制最大下落速度
		if velocity.y > FAST_MAX_FALL:
			velocity.y = FAST_MAX_FALL
	else:
		# 普通重力
		velocity.y += GRAVITY * delta
		if velocity.y > MAX_FALL:
			velocity.y = MAX_FALL


# 移动
func apply_horizontal_move(delta: float) -> void:
	# # 读取左右输入
	# var move_input: float = Input.get_action_strength("right") - Input.get_action_strength("left")
	# 目标最大速度：是否抱物？
	var max_speed: float = HOLDING_MAX_RUN if holding else MAX_RUN

	# # 当前是否在地面
	# var on_ground: bool = is_on_floor()

	# 加速倍率：地面 = 1，空中 = AIR_MULT
	var accel_mult: float = 1.0 if on_ground else AIR_MULT

	if move_input != 0.0:
		# 有输入 → 向目标速度逼近
		velocity.x = move_toward(velocity.x, move_input * max_speed, RUN_ACCEL * accel_mult * delta)
	else:
		# 无输入 → 速度衰减
		velocity.x = move_toward(velocity.x, 0, RUN_REDUCE * delta)


# 跳跃
func handle_jump_input(delta: float) -> void:
	# 检测按下跳跃键 → 启动缓冲
	if Input.is_action_just_pressed("jump"):
		buffer_timer = JUMP_BUFFER_TIME

	# 缓冲计时递减
	buffer_timer = max(buffer_timer - delta, 0.0)

	# 起跳条件：有缓冲 + 有宽容时间
	if buffer_timer > 0.0 and coyote_timer > 0.0 and can_jump:
		is_jumping = true
		velocity.y = - JUMP_SPEED
		var_jump_timer = VAR_JUMP_TIME
		buffer_timer = 0.0 # 消耗掉缓冲
		coyote_timer = 0.0 # 消耗掉宽容时间

	# 可变跳：松开跳跃键 → 立即结束可变时间
	if Input.is_action_just_released("jump"):
		var_jump_timer = 0.0

	# 如果在可变跳时间内并且仍在上升
	if var_jump_timer > 0.0 and velocity.y < 0:
		var_jump_timer -= delta
	elif velocity.y < 0 and not Input.is_action_pressed("jump"):
		velocity.y = velocity.y * 0.5 # 或者 velocity.y = max(velocity.y, -JUMP_SPEED * 0.5)
		var_jump_timer = 0.0


# 检测墙体连接
func check_wall_contact() -> void:
	# # 检测：是否仅碰到墙壁
	# if is_on_wall():
	#     # 获取最后一次碰撞的法线，x > 0 表示左墙，x < 0 表示右墙
	#     wall_dir = sign(get_last_slide_collision().get_normal().x)
	#     on_wall = true
	# else:
	#     # 没有碰到墙
	#     on_wall = false
	#     wall_dir = 0

	# 检测：是否仅碰到墙壁
	if hand_checker.is_colliding() or foot_checker.is_colliding():
		on_wall = true
	else:
		# 没有碰到墙
		on_wall = false
