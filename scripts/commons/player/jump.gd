extends State

func Begin() -> void:
    print("进入 Jump 状态")

func Update(delta: float) -> void:
    _owner.handle_jump_input(delta) # 跳跃

    # 进入 fall
    if _owner.velocity.y != 0 and not _owner.on_ground:
        change_state("Fall")

    # 进入 wall
    if _owner.can_on_wall:
        change_state("Wall")

    # 进入 slip
    if _owner.on_wall == true and _owner.move_input != 0.0 and not Input.is_action_pressed("grab"):
        change_state("Slip")
    
    # 播放动画
    _owner.animation.play("jump")

func End() -> void:
    _owner.is_jumping = false
    print("退出 Jump")