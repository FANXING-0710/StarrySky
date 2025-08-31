extends State

func Begin() -> void:
    print("进入 Jump 状态")
    # _owner.stop()   # 调用 Player.gd 的函数

func Update(delta: float) -> void:
    _owner.handle_jump_input(delta) # 跳跃
    _owner.animation.play("jump")

    if _owner.velocity.y != 0 and not _owner.on_ground:
        change_state("Fall")

    # 进入 wall
    if _owner.on_wall and Input.is_action_pressed("grab"):
        change_state("Wall")

func End() -> void:
    _owner.is_jumping = false
    print("退出 Jump")