extends State

func Begin() -> void:
    print("进入 Idle 状态")

func Update(delta: float) -> void:
    # 进入 fall
    if _owner.velocity.y > 0 and not _owner.on_ground:
        change_state("Fall")

    # 进入 run
    if _owner.move_input != 0 and _owner.velocity.x != 0:
        change_state("Run")
        
    # 进入 crouch
    # if Input.is_action_pressed("down") and _owner.velocity == Vector2.ZERO:
    #     change_state("Crouch")
        
    # 进入 jump
    if _owner.velocity.y < 0:
        change_state("Jump")

    # 进入 wall
    if _owner.on_wall and Input.is_action_pressed("grab") and _owner.stamina > 0:
        change_state("Wall")
    
    # 播放动画
    _owner.animation.play("idle")

    #TODO: https://chatgpt.com/c/68cd5aa8-f6f0-832a-a6b9-4e47fc07795f
        
func End() -> void:
    print("退出 Idle")
