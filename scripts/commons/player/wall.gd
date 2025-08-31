extends State

func Begin() -> void:
	_owner.can_apply_gravity = false
	_owner.velocity = Vector2(-_owner.wall_dir * _owner.WALL_JUMP_FORCE.x, -_owner.WALL_JUMP_FORCE.y)
	print("进入 Wall 状态")
	# _owner.stop()   # 调用 Player.gd 的函数

func Update(delta: float) -> void:
	_owner.velocity.y = 0
	_owner.animation.play("wall")

	_owner.stamina -= 10 * delta # 静止时也会慢慢耗体力

	# 进入 slip
	if _owner.stamina <= 0:
		change_state("Slip")

	# 进入 Climb 和 Slip 和 WallJump
	if Input.is_action_pressed("up"):
		change_state("Climb")
	elif Input.is_action_pressed("down"):
		change_state("Slip")
	elif Input.is_action_just_pressed("jump"):
		change_state("WallJump")
	
	# 进入 Fall
	if _owner.on_wall == false:
		change_state("Fall")

func End() -> void:
	_owner.can_apply_gravity = true
	print("退出 Wall")
