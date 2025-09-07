extends State

func Begin() -> void:
	_owner.can_apply_gravity = false
	_owner.can_move = false
	_owner.is_walling = true
	print("进入 Wall 状态")

func Update(delta: float) -> void:
	_owner.velocity.y = 0
	_owner.animation.play("wall")

	_owner.stamina -= 10 * delta

	# 进入 climb 或 slip
	if Input.is_action_pressed("up"):
		change_state("Climb")
	elif Input.is_action_pressed("down"):
		change_state("Slip")

	# 进入 slip
	if _owner.on_wall == true and _owner.stamina <= 0:
		change_state("Slip")
		
	if _owner.on_wall == false:
		change_state("Fall")

	# 进入 fall
	if _owner.on_wall == true and Input.is_action_just_released("grab") and _owner.move_input == 0.0:
		change_state("Fall")
	elif _owner.on_wall == true and Input.is_action_just_released("grab") and _owner.move_input != 0.0:
		change_state("Slip")
	

func End() -> void:
	_owner.can_apply_gravity = true
	_owner.can_move = true
	_owner.is_walling = false
	print("退出 Wall")
