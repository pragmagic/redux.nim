import sequtils
import ../redux/redux

type
  Todo = object
    text: string
    completed: bool

  VisibilityFilter = enum
    All,
    Done,
    Incomplete

  TodosStateObj = object
    filter: VisibilityFilter
    todos: seq[Todo]
  TodosState = ref TodosStateObj

  AddTodoAction = ref object of Action
    text: string

  ToggleTodoAction = ref object of Action
    index: Natural

  SetFilterAction = ref object of Action
    filter: VisibilityFilter

{.experimental.}

using
  state: TodosState
  action: Action
  filter: VisibilityFilter
  todo: Todo

proc `$`(filter): string =
  case filter
  of All: "All"
  of Done: "Done"
  of Incomplete: "Incomplete"

proc `$`(state): string =
  result = "Todos(" & $state.filter & "):\n"
  let todos = state.todos.filter(proc(todo): bool =
    state.filter == All or todo.completed and state.filter == Done or not todo.completed and state.filter == Incomplete
  )
  if len(todos) == 0:
    result &= "/empty/"
  else:
    for todo in todos:
      result &= (if todo.completed: "[x] " else: "[ ] ") & todo.text & "\n"

proc todos(state, action): TodosState =
  if state == nil:
    return TodosState(
      filter: VisibilityFilter.All,
      todos: @[]
    )
  new(result); result[] = state[]
  if action of SetFilterAction:
    result.filter = SetFilterAction(action).filter
  elif action of AddTodoAction:
    let todo = Todo(text: AddTodoAction(action).text)
    result.todos = todo & result.todos
  elif action of ToggleTodoAction:
    let index = ToggleTodoAction(action).index
    var todo = result.todos[index]
    todo.completed = not todo.completed
    result.todos[index] = todo
  else:
    result = state

var store = newStore(todos)

store.subscribe(proc (state) = echo $state)

store.dispatch(AddTodoAction(text: "First point"))
store.dispatch(AddTodoAction(text: "Next point"))
store.dispatch(ToggleTodoAction(index: 1))
store.dispatch(SetFilterAction(filter: Done))
store.dispatch(SetFilterAction(filter: Incomplete))
store.dispatch(ToggleTodoAction(index: 0))
