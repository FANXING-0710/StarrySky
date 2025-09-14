extends State

func Begin() -> void:
    print("进入 Jump 状态")

func Update(delta: float) -> void:
    # 进入 fall
    if _owner.velocity.y > 0 and not _owner.on_ground:
        change_state("Fall")
    
    # 播放动画
    _owner.animation.play("jump")

func End() -> void:
    print("退出 Jump")
