extends State

func Begin() -> void:
	_owner.can_apply_gravity = false
	print("进入 Wall 状态")

func Update(delta: float) -> void:
	_owner.velocity.y = 0
	_owner.animation.play("wall")

	_owner.stamina -= 10 * delta

	# 进入 climb
	if Input.is_action_pressed("up"):
		change_state("Climb")

	# 进入 fall
	if _owner.can_wall == false:
		change_state("Fall")

func End() -> void:
	_owner.can_apply_gravity = true
	print("退出 Wall")
