extends Node
class_name StateMachine

var current_state: Node = null
var states: Dictionary = {}
var history: Array[String] = []

## 当节点准备就绪时调用，初始化状态机
## 遍历所有子节点，将它们作为状态存储在states字典中
## 如果存在状态，则将第一个状态设置为初始状态
func _ready() -> void:
    # 遍历所有子节点，收集状态节点
    for child in get_children():
        if child is Node:
            states[child.name] = child
    # 如果有状态存在，将第一个状态设为当前状态
    if states.size() > 0:
        var first_state = states.values()[0]
        change_state(first_state.name)

## 每帧处理函数，用于更新当前状态
## @param delta: 与上一帧之间的时间间隔（秒）
func _process(delta: float) -> void:
    # 如果当前状态存在且有Update方法，则调用该方法
    if current_state and current_state.has_method("Update"):
        current_state.Update(delta)

## 切换到指定名称的新状态
## @param new_state_name: 要切换到的状态名称
func change_state(new_state_name: String) -> void:
    # 检查目标状态是否存在
    if not states.has(new_state_name):
        push_warning("State %s not found!" % new_state_name)
        return
    # 结束当前状态（如果存在）
    if current_state and current_state.has_method("End"):
        current_state.End()
    # 切换到新状态
    current_state = states[new_state_name]
    history.append(current_state.name)
    # 开始新状态（如果存在Begin方法）
    if current_state.has_method("Begin"):
        current_state.Begin()
    # 打印调试信息
    print_debug_chart()

## 启动指定状态的协程
## @param new_state_name: 要启动协程的状态名称
func start_coroutine(new_state_name: String) -> void:
    # 检查目标状态是否存在
    if not states.has(new_state_name):
        push_warning("Coroutine State %s not found!" % new_state_name)
        return
    # 获取状态节点并启动协程（如果存在）
    var state = states[new_state_name]
    if state.has_method("Coroutine"):
        await state.Coroutine()

## 打印状态机历史记录的调试图表
func print_debug_chart() -> void:
    # 构建历史记录图表字符串
    var chart := "\n=== 状态机历史记录 ===\n"
    for i in history.size():
        chart += str(i) + ": " + history[i]
        if i < history.size() - 1:
            chart += "  -->  "
        chart += "\n"
    chart += "============================="
    print(chart)