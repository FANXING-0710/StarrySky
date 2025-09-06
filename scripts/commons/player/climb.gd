extends State

func Begin() -> void:
	_owner.can_apply_gravity = false
	_owner.is_walling = true
	print("进入 Climb 状态")

func Update(delta: float) -> void:
	# _owner.animation.play("climb")
	_owner.animation.play("wall")

	_owner.stamina -= 30 * delta

	_owner.velocity.y = move_toward(_owner.velocity.y, -_owner.CLIMB_UP_SPEED, _owner.CLIMB_ACCEL * delta)

	# 进入 wall
	if _owner.on_wall == true and Input.is_action_just_released("up"):
		change_state("Wall")
	elif _owner.on_wall == true and not Input.is_action_pressed("up") and Input.is_action_just_pressed("down"):
		change_state("Slip")

	# 进入 slip
	if _owner.on_wall == true and _owner.stamina <= 0:
		change_state("Slip")
		
	# 进入 fall
	if _owner.on_wall == false or Input.is_action_just_released("grab"):
		change_state("Fall")

func End() -> void:
	_owner.can_apply_gravity = true
	_owner.is_walling = false
	print("退出 Climb")
