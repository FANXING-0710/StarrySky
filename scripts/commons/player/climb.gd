extends State

func Begin() -> void:
    _owner.is_walling = true
    _owner.can_apply_gravity = false
    _owner.can_move = false
    _owner.can_jump = false
    print("进入 Climb 状态")

func Update(delta: float) -> void:
    #TODO:
        #判断：如果手没有抓住墙，下面有则翻过了
        #翻过后加翻墙
    _owner.stamina -= 30 * delta
    _owner.velocity.y = move_toward(_owner.velocity.y, -_owner.CLIMB_UP_SPEED, _owner.CLIMB_ACCEL * delta)
    if Input.is_action_just_pressed("jump"):
        _owner.velocity = Vector2(0, -_owner.WALL_JUMP_FORCE.y)
        _owner.stamina -= _owner.CLIMB_JUMP_STAMINA_COST
        change_state("Jump")

    # 攀爬补偿
    if _owner.is_complete_climb == true and Input.is_action_pressed("up"):
        _owner.velocity.y = _owner.CLIMB_OFFSET.y
        Coroutine()
        await get_tree().create_timer(0.1).timeout
        _owner.velocity.x = _owner.CLIMB_OFFSET.x * _owner.wall_dir
        change_state("Fall")

    # 进入 wall 或 slip
    if Input.is_action_just_released("up"):
        change_state("Wall")
    elif not Input.is_action_pressed("up") and Input.is_action_just_pressed("down"):
        change_state("Slip")

    # 进入 fall 或 slip
    if _owner.wall_dir == -1 and Input.is_action_pressed("left") and Input.is_action_just_released("grab"):
        change_state("Slip")
    elif _owner.wall_dir == 1 and Input.is_action_pressed("right") and Input.is_action_just_released("grab"):
        change_state("Slip")
    elif Input.is_action_just_pressed("grab"):
        change_state("Fall")
    elif _owner.on_wall == false:
        change_state("Fall")

    # 进入 slip
    if _owner.stamina <= 0:
        change_state("Slip")
    
    # 播放动画
    # _owner.animation.play("climb")
    _owner.animation.play("wall")


func End() -> void:
    _owner.is_walling = false
    _owner.can_apply_gravity = true
    _owner.can_move = true
    _owner.can_jump = true
    print("退出 Climb")
