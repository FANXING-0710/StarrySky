extends State

func Begin() -> void:
	_owner.is_walling = true
	print("进入 Climb 状态")

func Update(delta: float) -> void:
	_owner.stamina -= 30 * delta

	_owner.velocity.y = move_toward(_owner.velocity.y, -_owner.CLIMB_UP_SPEED, _owner.CLIMB_ACCEL * delta)
		
	# 进入 fall
	if _owner.on_wall == false:
		change_state("Fall")

	# 进入 wall 或 slip
	if Input.is_action_just_released("up"):
		change_state("Wall")
	elif not Input.is_action_pressed("up") and Input.is_action_just_pressed("down"):
		change_state("Slip")

	# 进入 fall 或 slip
	if _owner.move_input == 0 and Input.is_action_just_released("grab"):
		change_state("Fall")
	elif _owner.move_input != 0 and Input.is_action_just_released("grab"):
		change_state("Slip")

	# 进入 slip
	if _owner.stamina <= 0:
		change_state("Slip")
	
	# 播放动画
	# _owner.animation.play("climb")
	_owner.animation.play("wall")


func End() -> void:
	_owner.is_walling = false
	print("退出 Climb")
