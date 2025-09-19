extends State

func Begin() -> void:
    _owner.is_walling = true
    _owner.can_apply_gravity = false
    _owner.can_move = false
    _owner.can_jump = false
    print("进入 Wall 状态")

func Update(delta: float) -> void:
    _owner.velocity.y = 0
    _owner.stamina -= 10 * delta
    if Input.is_action_just_pressed("jump") and _owner.move_input == 1:
        _owner.velocity = Vector2(-_owner.wall_dir * _owner.WALL_JUMP_FORCE.x, -_owner.WALL_JUMP_FORCE.y)
        _owner.stamina -= _owner.CLIMB_JUMP_STAMINA_COST
        change_state("Jump")
    elif Input.is_action_just_pressed("jump"):
        _owner.velocity = Vector2(0, -_owner.WALL_JUMP_FORCE.y)
        _owner.stamina -= _owner.CLIMB_JUMP_STAMINA_COST
        change_state("Jump")

    # 进入 climb 或 slip
    if Input.is_action_pressed("up"):
        change_state("Climb")
    elif Input.is_action_just_pressed("down"):
        change_state("Slip")

    # 进入 fall 和 run
    if _owner.move_input != 0 and Input.is_action_pressed("right") and Input.is_action_just_released("grab") and _owner.on_ground:
        change_state("Run")
    elif _owner.move_input != 0 and Input.is_action_pressed("left") and Input.is_action_just_released("grab") and _owner.on_ground:
        change_state("Run")
    elif Input.is_action_just_released("grab"):
        change_state("Fall")
    elif _owner.on_wall == false:
        change_state("Fall")

    # 进入 slip
    elif not Input.is_action_pressed("grab") and _owner.wall_dir == -1 and Input.is_action_pressed("left"):
        change_state("Slip")
    elif not Input.is_action_pressed("grab") and _owner.wall_dir == 1 and Input.is_action_pressed("right"):
        change_state("Slip")
    if _owner.stamina <= 0:
        change_state("Slip")


    # 播放动画
    _owner.animation.play("wall")

func End() -> void:
    _owner.is_walling = false
    _owner.can_apply_gravity = true
    _owner.can_move = true
    _owner.can_jump = true
    print("退出 Wall")
