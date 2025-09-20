extends State

func Begin() -> void:
    print("进入 Run 状态")
    
func Update(delta: float) -> void:
    # 进入 idle
    if _owner.velocity.x == 0 and _owner.move_input == 0:
        change_state("Idle")

    # 进入 fall
    if _owner.velocity.y > 0 and not _owner.on_ground:
        change_state("Fall")

    # 进入 wall
    if _owner.on_wall and Input.is_action_pressed("grab") and _owner.stamina > 0:
        change_state("Wall")

    if _owner.velocity.y < 0:
        change_state("Jump")
        
    # 播放动画
    _owner.animation.play("run")

func End() -> void:
    print("退出 Run")