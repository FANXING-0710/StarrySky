extends State

func Begin() -> void:
    _owner.can_apply_gravity = false
    print("进入 Slip 状态")
    # _owner.stop()   # 调用 Player.gd 的函数

func Update(delta: float) -> void:
    # _owner.animation.play("slip")
    _owner.animation.play("wall")

    if _owner.stamina <= 0:
        _owner.velocity.y = _owner.CLIMB_SLIP_SPEED
    elif Input.is_action_pressed("down") and _owner.stamina > 0:
                # 逐渐逼近向下速度（+80）
        _owner.velocity.y = move_toward(_owner.velocity.y, _owner.CLIMB_DOWN_SPEED, _owner.CLIMB_ACCEL * delta)
        # 下爬不消耗体力
    elif Input.is_action_just_released("down") and _owner.stamina > 0:
        change_state("Wall")
    
    if _owner.on_ground:
        change_state("Idle")

func End() -> void:
    print("退出 Slip")