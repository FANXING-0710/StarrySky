extends State

func Begin() -> void:
	_owner.can_jump = false
	print("进入 Fall 状态")

func Update(delta: float) -> void:
	_owner.animation.play("fall")

	# 进入 idle
	if _owner.on_ground:
		change_state("Idle")

	# 进入 wall
	if _owner.can_wall == true:
		change_state("Wall")

func End() -> void:
	_owner.can_jump = true
	print("退出 Fall")
