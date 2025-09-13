extends State

func Begin() -> void:
	_owner.can_jump = false
	print("进入 Fall 状态")

func Update(delta: float) -> void:
	if _owner.wall_grace_timer > 0.0 and Input.is_action_just_pressed("jump"):
			_owner.velocity = Vector2(-_owner.wall_dir * _owner.WALL_JUMP_FORCE.x, -_owner.WALL_JUMP_FORCE.y)

	# 进入 idle
	if _owner.on_ground:
		change_state("Idle")

	# 进入 slip
	if _owner.on_wall == true and not Input.is_action_pressed("grab") and _owner.wall_dir == -1 and Input.is_action_pressed("left"):
		change_state("Slip")
	elif _owner.on_wall == true and not Input.is_action_pressed("grab") and _owner.wall_dir == 1 and Input.is_action_pressed("right"):
		change_state("Slip")

	# 进入 wall
	if _owner.can_on_wall:
		change_state("Wall")

	# 播放动画
	_owner.animation.play("fall")

func End() -> void:
	_owner.can_jump = true
	print("退出 Fall")
