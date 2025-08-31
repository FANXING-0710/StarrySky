extends State

func Begin() -> void:
    _owner.can_apply_gravity = false
    print("进入 Climb 状态")
    # _owner.stop()   # 调用 Player.gd 的函数

func Update(delta: float) -> void:
    # _owner.animation.play("climb")
    _owner.animation.play("wall")

    if Input.is_action_pressed("up") and _owner.on_ground:
        # 逐渐逼近向上速度（-45），模拟加速感
        _owner.velocity.y = move_toward(_owner.velocity.y, -_owner.CLIMB_UP_SPEED,_owner. CLIMB_ACCEL * delta)
        _owner.stamina -= 30 * delta   # 上爬快速消耗体力
    elif Input.is_action_just_released("up"):
        change_state("Wall")

func End() -> void:
    print("退出 Climb")