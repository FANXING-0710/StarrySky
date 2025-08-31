extends State

func Begin() -> void:
    _owner.stamina -= 20
    _owner.velocity = Vector2(-_owner.wall_dir * _owner.WALL_JUMP_FORCE.x, -_owner.WALL_JUMP_FORCE.y)
    print("进入 WallJump 状态")
    # _owner.stop()   # 调用 Player.gd 的函数

func Update(delta: float) -> void:
    _owner.animation.play("jump")

    if _owner.velocity.y != 0 and not _owner.on_ground:
        change_state("Fall")

func End() -> void:
    _owner.is_jumping = false
    print("退出 WallJump")