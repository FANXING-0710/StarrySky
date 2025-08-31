extends State

func Begin() -> void:
	_owner.can_jump = false
	print("进入 Fall 状态")
	# _owner.stop()   # 调用 Player.gd 的函数

func Update(delta: float) -> void:
	_owner.animation.play("fall")
	if _owner.on_ground:
		change_state("Idle")

	# 进入 wall
	if _owner.on_wall and Input.is_action_pressed("grab"):
		change_state("Wall")

func End() -> void:
	_owner.can_jump = true
	print("退出 Fall")
