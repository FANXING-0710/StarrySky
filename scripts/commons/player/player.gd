extends CharacterBody2D

# 获取动画精灵节点，用于播放角色动画
@onready var animation: AnimatedSprite2D = $Grapsics/Animation
# 手部射线检测，用于检测墙壁碰撞
@onready var hand_checker: RayCast2D = $Grapsics/HandChecker
# 脚部射线检测，用于检测墙壁碰撞
@onready var foot_checker: RayCast2D = $Grapsics/FootChecker
# 图形节点，用于控制角色朝向
@onready var grapsics: Node2D = $Grapsics

## 物理常数
const GRAVITY: float = 900.0 # 普通重力加速度
const FAST_FALL_GRAVITY: float = 2000.0 # 快速下落时的重力加速度
const MAX_FALL: float = 160.0 # 最大下落速度（普通）
const FAST_MAX_FALL: float = 240.0 # 最大下落速度（快速下落）
## 奔跑相关
const MAX_RUN: float = 90.0 # 最大奔跑速度
const HOLDING_MAX_RUN: float = 70.0 # 抱物时最大奔跑速度
const RUN_ACCEL: float = 1000.0 # 加速度
const RUN_REDUCE: float = 400.0 # 摩擦/减速率
const AIR_MULT: float = 0.65 # 空中加速倍率
## 跳跃相关
const JUMP_SPEED: float = 105.0 * 2.5 # 跳跃初速度
const VAR_JUMP_TIME: float = 0.20 # 可变跳窗口
const JUMP_COYOTE_TIME: float = 0.10 # 落地后宽容时间
const JUMP_BUFFER_TIME: float = 0.10 # 提前按键缓冲
## 攀爬相关
const CLIMB_MAX_STAMINA: float = 110.0 # 最大体力值
const CLIMB_UP_SPEED: float = 45 # 向上攀爬速度（像素/秒）
const CLIMB_DOWN_SPEED: float = 80.0 # 向下攀爬速度（像素/秒）
const CLIMB_SLIP_SPEED: float = 30.0 # 体力耗尽时的滑落速度
const CLIMB_ACCEL: float = 900.0 # 攀爬加速度，让速度逐渐逼近目标值
const CLIMB_OFFSET: Vector2 = Vector2(65, -100) # 爬过墙的补偿
# 墙体跳跃
const WALL_JUMP_FORCE: Vector2 = Vector2(120.0, 105.0) # 蹬墙跳速度
const WALL_JUMP_GRACE: float = 0.10 # 离开墙壁后还能蹬的缓冲时间
const CLIMB_JUMP_STAMINA_COST: float = 20.0 # 攀爬跳体力消耗
## Dash
const DASH_SPEED: float = 240.0 # 冲刺速度
const DASH_TIME: float = 0.15 # 冲刺持续时间
const DASH_COOLDOWN: float = 0.2 # 冲刺结束后冷却时间
const MAX_DASHES: int = 1 # 默认 1 次 Dash（后期可升级到 2 次）
const DASH_LAND_JUMP_WINDOW: float = 0.1 # Dash落地后的跳跃时间窗口
## 高级冲刺技巧相关
const SUPER_BOOST: float = 1.3 # Super dash的跳跃加成
const HYPER_BOOST_X: float = 1.8 # Hyper dash的水平速度加成
const HYPER_BOOST_Y: float = 0.7 # Hyper dash的垂直速度减少
const ULTRA_BOOST: float = 1.2 # Ultra dash的速度保持加成
const ULTRA_MIN_HEIGHT: float = 28.0 # Ultra所需的最低高度差（像素）
const SUPER_TIME_WINDOW: float = 0.1 # Super Dash 触发时间窗口（秒）

## 变量
# var velocity: Vector2 # CharacterBody2D的隐藏变量
var holding: bool = false # 是否正在抱物体
var move_input: float = Input.get_action_strength("right") - Input.get_action_strength("left") # 读取左右输入（1：右，-1：左）
var on_ground: bool = is_on_floor() # 当前是否在地面
var can_apply_gravity: bool = true # 是否可以应用重力
var can_move: bool = true # 是否可以应用移动
# 跳跃相关
var can_jump: bool = true
var var_jump_timer: float = 0.0 # 可变跳定时器
var coyote_timer: float = 0.0 # Coyote Time
var buffer_timer: float = 0.0 # 提前按跳缓冲
# 攀爬相关
var stamina: float = CLIMB_MAX_STAMINA # 当前体力
var is_walling: bool = false # 是否正在墙上
var on_wall: bool = false # 是否在贴墙
var wall_dir: int = 0 # 贴哪一边的墙：-1：左墙，1：右墙
var is_complete_climb: bool = false # 是否完成攀爬
var wall_grace_timer: float = 0.0 # 离墙缓冲计时
# Dash
var dash_dir: Vector2 = Vector2.ZERO # 当前冲刺方向
var dashes_left: int = MAX_DASHES # 剩余 Dash 数
var is_dashing: bool = false # 是否正在冲刺
var dash_timer: float = 0.0 # 冲刺计时
var dash_cooldown: float = 0.0 # 冲刺冷却计时
var was_dashing: bool = false # 上一帧是否在冲刺
var dash_land_timer: float = 0.0 # Dash落地后的特殊跳跃时间窗口
# 高级冲刺技巧
var is_super_dashing: bool = false # 是否正在执行 Super dash
var is_hyper_dashing: bool = false # 是否正在执行 Hyper dash
var is_ultra_dashing: bool = false # 是否正在执行 Ultra dash
var hyper_charge_time: float = 0.0 # Hyper 充能计时器
var ultra_start_velocity: Vector2 = Vector2.ZERO # Ultra 开始时的速度
var super_dash_timer: float = 0.0 # Super Dash 触发计时器

func _physics_process(delta: float) -> void:
    ## 更新变量
    # 更新输入方向
    move_input = Input.get_action_strength("right") - Input.get_action_strength("left") # 更新输入
    # 更新地面状态
    on_ground = is_on_floor()
    # 更新离墙缓冲计时器
    wall_grace_timer = max(wall_grace_timer - delta, 0.0)

    # 检测Dash落地
    if was_dashing and on_ground and not is_dashing:
        dash_land_timer = DASH_LAND_JUMP_WINDOW
    else:
        dash_land_timer = max(dash_land_timer - delta, 0.0)
    
    # 记录上一帧的Dash状态
    was_dashing = is_dashing

    # 处理高级冲刺技巧
    handle_advanced_tech(delta)
    
    # 如果可以应用重力，则应用重力
    if can_apply_gravity == true:
        apply_gravity(delta) # 重力
    
    # 如果在地面上，恢复体力
    if on_ground:
        stamina = CLIMB_MAX_STAMINA

    ## 跳跃相关
    # 更新 Coyote Time（落地后仍可跳跃的宽容时间）
    if on_ground:
        coyote_timer = JUMP_COYOTE_TIME
    else:
        coyote_timer = max(coyote_timer - delta, 0.0)
    # 如果可以跳跃，处理跳跃输入
    if can_jump == true:
        handle_jump_input(delta) # 跳跃

    ## Dash相关
    if is_dashing:
        # 减少冲刺计时
        dash_timer -= delta
        if dash_timer <= 0.0:
            # 冲刺结束
            end_dash()
        else:
            # Dash 期间锁定速度
            velocity = dash_dir * DASH_SPEED
    elif dash_cooldown > 0.0:
        # 减少冲刺冷却时间
        dash_cooldown -= delta

    # 落地恢复 dash 次数
    if is_on_floor():
        dashes_left = MAX_DASHES

    # 处理冲刺输入
    handle_dash_input()
    # 处理角色朝向反转
    direction_reversal()
    # 检查墙壁碰撞
    check_wall()
    # 应用水平移动
    apply_horizontal_move(delta)
    # 应用物理移动
    move_and_slide()
    
    # # 调试信息
    # if Input.is_action_just_pressed("dash"):
    #     print("Dash输入: 方向=", dash_dir, " 在地面=", on_ground)
    # if Input.is_action_just_pressed("jump") and is_dashing:
    #     print("Jump during Dash: Super timer=", super_dash_timer)
    # if Input.is_action_just_pressed("jump"):
    #     print("Jump pressed: is_jumping=", is_jumping(), " buffer_timer=", buffer_timer)


# 方向反转函数
func direction_reversal() -> void:
    # 如果有输入且不在墙上，根据输入方向反转角色朝向
    if move_input != 0.0 and not is_walling:
        grapsics.scale.x = move_input

# 重力应用函数
func apply_gravity(delta: float) -> void:
    # 是否按下"向下键" → 快速下落
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
        # 限制最大下落速度
        if velocity.y > MAX_FALL:
            velocity.y = MAX_FALL

# 水平移动应用函数
func apply_horizontal_move(delta: float) -> void:
    # 如果不能移动，将水平速度设为0
    if can_move == false:
        velocity.x = 0
        return

    # 目标最大速度：是否抱物？
    var max_speed: float = HOLDING_MAX_RUN if holding else MAX_RUN
    # 加速倍率：地面 = 1，空中 = AIR_MULT
    var accel_mult: float = 1.0 if on_ground else AIR_MULT

    if move_input != 0.0:
        # 有输入 → 向目标速度逼近
        velocity.x = move_toward(velocity.x, move_input * max_speed, RUN_ACCEL * accel_mult * delta)
    else:
        # 无输入 → 速度衰减
        velocity.x = move_toward(velocity.x, 0, RUN_REDUCE * delta)

# 检查是否处于跳跃状态
func is_jumping() -> bool:
    return velocity.y < 0 or var_jump_timer > 0

# 跳跃输入处理函数 - 修改版
func handle_jump_input(delta: float) -> void:
    # 检测按下跳跃键 → 启动缓冲（只有在不处于跳跃状态时）
    if Input.is_action_just_pressed("jump") and not is_jumping():
        buffer_timer = JUMP_BUFFER_TIME

    # 缓冲计时递减
    buffer_timer = max(buffer_timer - delta, 0.0)

    # 起跳条件：有缓冲 + 有宽容时间 + 不处于跳跃状态
    if buffer_timer > 0.0 and (coyote_timer > 0.0 or on_ground or dash_land_timer > 0.0) and not is_jumping():
        # 应用跳跃速度 - 保留水平动量
        var jump_power = JUMP_SPEED
        
        # 如果是Dash落地跳跃，给予额外加成
        if dash_land_timer > 0.0:
            # 继承Dash的水平动量并给予加成
            var horizontal_boost = 1.5  # 水平动量加成系数
            velocity.x *= horizontal_boost
            
            # 稍微增加跳跃高度
            jump_power *= 1.1
            
            # 重置Dash落地计时器
            dash_land_timer = 0.0
            
            # 可以在这里添加视觉/音频反馈
            # print("Dash落地跳跃!")
        
        velocity.y = -jump_power
        # 设置可变跳跃时间
        var_jump_timer = VAR_JUMP_TIME
        # 消耗掉缓冲
        buffer_timer = 0.0
        # 消耗掉宽容时间
        coyote_timer = 0.0

    # 可变跳：松开跳跃键 → 立即结束可变时间
    if Input.is_action_just_released("jump"):
        var_jump_timer = 0.0

    # 如果在可变跳时间内并且仍在上升
    if var_jump_timer > 0.0 and velocity.y < 0:
        # 减少可变跳跃时间
        var_jump_timer -= delta
    elif velocity.y < 0 and not Input.is_action_pressed("jump"):
        # 如果松开跳跃键且仍在上升，减少上升速度
        velocity.y = max(velocity.y, -JUMP_SPEED * 0.5)
        # 结束可变跳跃
        var_jump_timer = 0.0

# 墙壁检测函数
func check_wall() -> void:
    # 检测：是否碰到墙壁
    if hand_checker.is_colliding() or foot_checker.is_colliding():
        # 设置墙壁接触状态
        on_wall = true
        # 重置离墙缓冲时间
        wall_grace_timer = WALL_JUMP_GRACE

        # 判断贴墙方向
        var wall_normal: Vector2
        if hand_checker.is_colliding():
            # 获取手部碰撞法线
            wall_normal = hand_checker.get_collision_normal()
        else:
            # 获取脚部碰撞法线
            wall_normal = foot_checker.get_collision_normal()
        # 根据法线方向判断是左墙还是右墙
        if wall_normal.x > 0: # 法线向右，说明是左墙
            wall_dir = -1
        elif wall_normal.x < 0: # 法线向左，说明是右墙
            wall_dir = 1
    else:
        # 没有碰到墙
        on_wall = false

    # 检测：是否完成攀爬（手部离开墙但脚部仍在墙上）
    if not hand_checker.is_colliding() and foot_checker.is_colliding():
        is_complete_climb = true
    else:
        is_complete_climb = false

## Dash
# Dash输入处理函数
func handle_dash_input() -> void:
    # 如果按下冲刺键、有冲刺次数、不在冲刺状态且冷却结束
    if Input.is_action_just_pressed("dash") and dashes_left > 0 and not is_dashing and dash_cooldown <= 0.0:
        start_dash()

# 开始Dash函数
func start_dash() -> void:
    # 禁用跳跃
    can_jump = false
    # 读取方向输入
    var input_dir = Vector2(
        Input.get_action_strength("right") - Input.get_action_strength("left"),
        Input.get_action_strength("down") - Input.get_action_strength("up")
    )
    
    # 只有在没有方向输入时才使用面向方向
    if input_dir == Vector2.ZERO:
        input_dir = Vector2(grapsics.scale.x, 0)
    
    # 标准化冲刺方向
    dash_dir = input_dir.normalized()
    
    # 设置冲刺状态
    is_dashing = true
    # 设置冲刺计时
    dash_timer = DASH_TIME
    # 重置 Super Dash 计时器
    super_dash_timer = SUPER_TIME_WINDOW
    # 减少冲刺次数
    dashes_left -= 1
    # 设置冲刺速度
    velocity = dash_dir * DASH_SPEED

# 停止Dash函数 - 修改版
func end_dash() -> void:
    # 启用跳跃
    can_jump = true
    # 重置冲刺状态
    is_dashing = false
    # 重置冲刺计时
    dash_timer = 0.0
    # 设置冲刺冷却
    dash_cooldown = DASH_COOLDOWN
    # dash 结束后，速度会保留一部分（模拟 Celeste 手感）
    # 但垂直速度保留较少，水平速度保留较多
    velocity.x *= 0.8  # 增加水平速度保留
    velocity.y *= 0.4  # 减少垂直速度保留

## 高级冲刺技巧处理函数
func handle_advanced_tech(delta: float) -> void:
    # 更新 Super Dash 计时器
    if is_dashing:
        super_dash_timer = max(super_dash_timer - delta, 0.0)
    
    # 首先检查Ultra Dash（优先级最高）
    if is_dashing and not on_ground and dash_dir.y > 0 and dash_dir.x != 0:
        try_start_ultra_dash()
        return # 如果触发了Ultra，就不检查其他技巧
    
    # 然后检查Hyper Dash（在地面斜下Dash期间按跳跃键）
    if is_dashing and on_ground and dash_dir.y > 0 and dash_dir.x != 0:
        if Input.is_action_just_pressed("jump"):
            start_hyper_dash()
            return
    
    # 然后检查Super Dash（添加时间窗口限制）
    if is_dashing and on_ground and dash_dir.y == 0 and Input.is_action_just_pressed("jump") and super_dash_timer > 0:
        start_super_dash()
        return # 如果触发了Super，就不检查其他技巧
    
    # Ultra Dash速度保持
    if is_ultra_dashing and on_ground:
        # 触地时保持并增加速度
        velocity.x *= ULTRA_BOOST
        is_ultra_dashing = false

## 开始Super Dash函数
func start_super_dash() -> void:
    # 设置Super Dash状态
    is_super_dashing = true
    # 结束普通Dash
    end_dash()
    
    # 应用Super Dash效果: 更高更远的跳跃
    velocity.y = - JUMP_SPEED * SUPER_BOOST
    velocity.x = dash_dir.x * DASH_SPEED * SUPER_BOOST
    
    # 短暂禁用重力，让跳跃更流畅
    can_apply_gravity = false
    # 0.2秒后恢复重力
    await get_tree().create_timer(0.2).timeout
    can_apply_gravity = true
    # 重置Super Dash状态
    is_super_dashing = false

## 开始Hyper Dash函数
func start_hyper_dash() -> void:
    # 设置Hyper Dash状态
    is_hyper_dashing = true
    
    # 结束普通Dash
    end_dash()
    
    # 应用Hyper Dash效果: 更快更远但高度较低
    # 使用dash_dir.x而不是grapsics.scale.x，因为dash_dir已经包含了输入方向
    velocity.y = -JUMP_SPEED * HYPER_BOOST_Y
    velocity.x = dash_dir.x * DASH_SPEED * HYPER_BOOST_X
    
    # 重置Hyper Dash状态
    is_hyper_dashing = false

## 尝试开始Ultra Dash函数
func try_start_ultra_dash() -> void:
    # 检查是否满足Ultra条件: 足够的高度差
    var space_state = get_world_2d().direct_space_state
    
    # 计算射线起点（角色底部）
    var ray_start = global_position + Vector2(0, 10) # 假设角色高度为20像素，从底部上方10像素开始
    
    # 创建射线查询参数
    var query = PhysicsRayQueryParameters2D.create(
        ray_start,
        ray_start + Vector2(0, ULTRA_MIN_HEIGHT),
        collision_mask
    )
    # 排除角色自身的碰撞
    query.exclude = [self]
    
    # 执行射线检测
    var result = space_state.intersect_ray(query)
    
    # 打印调试信息
    # print("Ultra Dash检测: 从 ", ray_start, " 到 ", ray_start + Vector2(0, ULTRA_MIN_HEIGHT))
    # print("碰撞结果: ", result)
    
    # 如果没有碰撞到任何东西，说明高度足够
    if not result:
        start_ultra_dash()
    # else:
    #     print("Ultra Dash条件不满足: 碰撞到 ", result.collider.name)

## 开始Ultra Dash函数
func start_ultra_dash() -> void:
    # 设置Ultra Dash状态
    is_ultra_dashing = true
    # 保存开始时的速度
    ultra_start_velocity = velocity
    # 结束普通Dash
    end_dash()
    
    # Ultra Dash期间保持动量
    velocity = ultra_start_velocity
    
    # 注意: Ultra的关键在于斜下冲刺结束后触地时不会重置速度
    # 这已经在handle_advanced_tech中的ultra_dashing检查处理