import ../redux/ [redux, undoable]

when not defined(js) and not defined(Nimdoc):
  {.error: "These tests are designed to reproduce issues when compiling for the JavaScript platform.".}

type
  StateObj = object
    status: string
  State = ref StateObj
  UpdateStatusAction = ref object of Action
    status: string

proc `$`(state: UndoableState[State]): string =
  result = state.repr()

{.experimental.}
using
  state: State
  action: Action

proc domaction(state, action): State =
  if state == nil:
    return State()
  elif action of UpdateStatusAction:
    state.status = UpdateStatusAction(action).status
  return state

var store = newStore(undoable(domaction))
store.subscribe(proc (state: UndoableState[State]) = echo $state)
store.dispatch(UpdateStatusAction(status: "New status"))
doAssert(store.getState().getPresent().status == "New status")