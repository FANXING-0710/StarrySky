extends State

func Begin() -> void:
	_owner.is_walling = true
	_owner.can_apply_gravity = false
	_owner.can_move = false
	_owner.can_jump = false
	print("进入 Slip 状态")

func Update(delta: float) -> void:
	_owner.velocity.y = move_toward(_owner.velocity.y, _owner.CLIMB_DOWN_SPEED, _owner.CLIMB_ACCEL * delta)
		
	# 进入 fall
	if _owner.on_wall == false:
		change_state("Fall")
	if Input.is_action_just_released("grab"):
		change_state("Fall")
	if _owner.wall_dir == -1 and Input.is_action_just_released("left"):
		change_state("Fall")
	elif _owner.wall_dir == 1 and Input.is_action_just_released("right"):
		change_state("Fall")
	if _owner.wall_dir == -1 and Input.is_action_pressed("right") and not Input.is_action_pressed("left"):
		change_state("Fall")
	elif _owner.wall_dir == 1 and Input.is_action_pressed("left") and not Input.is_action_pressed("right"):
		change_state("Fall")


	# 进入 wall
	if Input.is_action_just_pressed("grab"):
		change_state("Wall")
	if Input.is_action_just_released("down"):
		change_state("Wall")
	
	# 进入 idle 或 run
	if not Input.is_action_pressed("grab") and _owner.on_ground and _owner.move_input != 0.0:
		change_state("Run")
	elif not Input.is_action_pressed("grab") and _owner.on_ground and _owner.move_input == 0.0:
		change_state("Idle")

	# 播放动画
	# _owner.animation.play("slip")
	_owner.animation.play("wall")
	
func End() -> void:
	_owner.is_walling = false
	_owner.can_apply_gravity = true
	_owner.can_move = true
	_owner.can_jump = true
	print("退出 Slip")
