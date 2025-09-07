extends State

func Begin() -> void:
    _owner.stamina = _owner.CLIMB_MAX_STAMINA
    print("进入 Idle 状态")

func Update(delta: float) -> void:
    # 进入 fall
    if _owner.velocity.y != 0 and not _owner.is_jumping:
        change_state("Fall")

    # 进入 run
    if _owner.move_input != 0 and _owner.velocity.x != 0:
        change_state("Run")
        
    # 进入 crouch
    if Input.is_action_pressed("down"):
        change_state("Crouch")
        
    # 进入 jump
    if _owner.is_jumping:
        change_state("Jump")

    # 进入 wall
    if _owner.can_on_wall:
        change_state("Wall")
    
    # 播放动画
    _owner.animation.play("idle")
        
func End() -> void:
    print("退出 Idle")
