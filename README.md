# Redux.nim

Redux.nim is a predictable state container for Nim apps. Nim version of [Redux.js](http://redux.js.org/).

## Examples

To run the examples below:

```
  nimble install # For first time
```

```
  cd examples/
  nim c -r counter.nim
  nim c -r todos.nim
  nim c -r todosundoable.nim
```

### Counter

```nim
type
  CounterState = int
  IncrementAction = ref object of Action
  DecrementAction = ref object of Action

proc counter(state: CounterState, action: Action): CounterState =
  if action of IncrementAction:
    result = state + 1
  elif action of DecrementAction:
    result = state - 1
  else:
    result = state

var store = newStore(counter)

store.dispatch(IncrementAction())
echo store.getState()

store.dispatch(DecrementAction())
echo store.getState()
```

Output:

```
1
0
```

### Todos with Undo/Redo

```nim
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

proc `$`(state: UndoableState[TodosState]): string =
  let state = state.getPresent()
  result = "Todos(" & $state.filter & "):\n"
  let todos = state.todos.filter(proc(todo): bool =
    state.filter == All or todo.completed and state.filter == Done or not todo.completed and state.filter == Incomplete
  )
  if len(todos) == 0:
    result &= "/empty/\n"
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

var store = newStore(undoable(todos))

store.subscribe(proc (state: UndoableState[TodosState]) = echo $state)

store.dispatch(AddTodoAction(text: "First point"))
store.dispatch(UndoAction())
store.dispatch(RedoAction())
store.dispatch(AddTodoAction(text: "Next point"))
store.dispatch(ToggleTodoAction(index: 1))
store.dispatch(SetFilterAction(filter: Done))
store.dispatch(SetFilterAction(filter: Incomplete))
store.dispatch(ToggleTodoAction(index: 0))
store.dispatch(UndoAction())
store.dispatch(UndoAction())
store.dispatch(UndoAction())
store.dispatch(UndoAction())
store.dispatch(UndoAction())
store.dispatch(UndoAction())
```

Output:

```
Todos(All):
[ ] First point

Todos(All):
/empty/

Todos(All):
[ ] First point

Todos(All):
[ ] Next point
[ ] First point

Todos(All):
[ ] Next point
[x] First point

Todos(Done):
[x] First point

Todos(Incomplete):
[ ] Next point

Todos(Incomplete):
/empty/

Todos(Incomplete):
[ ] Next point

Todos(Done):
[x] First point

Todos(All):
[ ] Next point
[x] First point

Todos(All):
[ ] Next point
[ ] First point

Todos(All):
[ ] First point

Todos(All):
/empty/
```

## TODO

* Add `combineReducers`.
* Elaborate on asyncrounus dispatch.
* Elaborate on middleware.

## License

This library is licensed under the MIT license. Read [LICENSE](https://github.com/pragmagic/redux.nim/blob/master/LICENSE) file for details.

Copyright (c) 2017 Pragmagic, Inc.
