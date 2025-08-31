extends Node
class_name State

var _state_machine: StateMachine
var _owner: Node

## 当节点准备就绪时调用此函数
## 初始化状态机引用和所有者节点引用
func _ready() -> void:
    _state_machine = get_parent() as StateMachine
    if _state_machine:
        _owner = _state_machine.get_parent()

## 切换到指定名称的状态
## @param state_name: 目标状态的名称
func change_state(state_name: String) -> void:
    if _state_machine:
        _state_machine.change_state(state_name)

## 启动指定名称状态的协程
## @param state_name: 目标状态的名称
func start_coroutine(state_name: String) -> void:
    if _state_machine:
        _state_machine.start_coroutine(state_name)

## 状态开始时调用的函数
## 子类应重写此函数以实现具体的状态初始化逻辑
func Begin() -> void:
    pass

## 状态更新时调用的函数
## 子类应重写此函数以实现具体的状态更新逻辑
## @param delta: 自上一帧以来经过的时间(秒)
func Update(delta: float) -> void:
    pass

## 状态结束时调用的函数
## 子类应重写此函数以实现具体的状态清理逻辑
func End() -> void:
    pass

## 状态协程函数
## 创建一个1秒的计时器，等待计时器超时后打印协程完成信息
func Coroutine() -> void:
    # await get_tree().create_timer(1.0).timeout
    # print("%s Coroutine finished" % name)
    pass