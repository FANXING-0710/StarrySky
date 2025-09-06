extends State

func Begin() -> void:
    print("进入 Jump 状态")

func Update(delta: float) -> void:
    _owner.handle_jump_input(delta) # 跳跃
    _owner.animation.play("jump")

    # 进入 fall
    if _owner.velocity.y != 0 and not _owner.on_ground:
        change_state("Fall")

    # 进入 wall
    if _owner.on_wall == true and Input.is_action_pressed("grab"):
        change_state("Wall")

func End() -> void:
    _owner.is_jumping = false
    print("退出 Jump")