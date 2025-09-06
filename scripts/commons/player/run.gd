extends State

func Begin() -> void:
    print("进入 Run 状态")
    # _owner.stop()   # 调用 Player.gd 的函数

func Update(delta: float) -> void:
    _owner.animation.play("run")

    # 进入 idle
    if _owner.velocity.x == 0 and _owner.move_input == 0:
        change_state("Idle")

    # 进入 fall
    if _owner.velocity.y > 0:
        change_state("Fall")

    # 进入 wall
    if _owner.on_wall == true and Input.is_action_pressed("grab"):
        change_state("Wall")

    if _owner.is_jumping:
        change_state("Jump")

func End() -> void:
    print("退出 Run")