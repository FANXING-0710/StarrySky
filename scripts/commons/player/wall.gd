extends State

func Begin() -> void:
	_owner.is_walling = true
	print("进入 Wall 状态")

func Update(delta: float) -> void:
	_owner.velocity.y = 0

	_owner.stamina -= 10 * delta

	# 进入 fall
	if not Input.is_action_pressed("grab") and _owner.move_input != 0.0:
		change_state("Slip")
	elif not Input.is_action_pressed("grab"):
		change_state("Fall")

	# 进入 climb 或 slip
	if Input.is_action_pressed("up"):
		change_state("Climb")
	elif Input.is_action_pressed("down"):
		change_state("Slip")

	# 进入 slip
	if _owner.stamina <= 0:
		change_state("Slip")
		
	if _owner.on_wall == false:
		change_state("Fall")
	
	# 播放动画
	_owner.animation.play("wall")

func End() -> void:
	_owner.is_walling = false
	print("退出 Wall")
