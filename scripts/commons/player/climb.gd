extends State

func Begin() -> void:
	_owner.can_apply_gravity = false
	print("进入 Climb 状态")

func Update(delta: float) -> void:
	# _owner.animation.play("climb")
	_owner.animation.play("wall")

	_owner.stamina -= 30 * delta

	_owner.velocity.y = move_toward(_owner.velocity.y, -_owner.CLIMB_UP_SPEED, _owner.CLIMB_ACCEL * delta)

	# 进入 wall
	if _owner.can_wall == true and Input.is_action_just_released("up"):
		change_state("Wall")

	# 进入 fall
	if _owner.can_wall == false:
		change_state("Fall")

func End() -> void:
	_owner.can_apply_gravity = true
	print("退出 Climb")
