extends State

func Begin() -> void:
    _owner.can_move = false
    _owner.can_jump = false
    print("进入 Crouch 状态")
    # _owner.stop()   # 调用 Player.gd 的函数

func Update(delta: float) -> void:
    _owner.velocity = Vector2.ZERO

    _owner.animation.play("crouch")

    if Input.is_action_just_released("down"):
        change_state("Idle")
        _owner.can_jump = true

    if _owner.on_ground == false:
        change_state("Fall")

func End() -> void:
    print("退出 Crouch")
    _owner.can_move = true
