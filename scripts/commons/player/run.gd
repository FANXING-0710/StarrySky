extends State

func Begin() -> void:
    print("进入 Run 状态")
    # _owner.stop()   # 调用 Player.gd 的函数

func Update(delta: float) -> void:
    _owner.animation.play("run")

    if _owner.velocity.x == 0 and _owner.move_input == 0:
        change_state("Idle")

    if _owner.velocity.y != 0 and not _owner.is_jumping:
        change_state("Fall")

    if _owner.is_jumping:
        change_state("Jump")

func End() -> void:
    print("退出 Run")