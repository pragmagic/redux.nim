import ../redux

type
  CounterState = ref object
    count: int
  IncrementAction = ref object of Action
  DecrementAction = ref object of Action

proc counter(state: CounterState, action: Action): CounterState =
  if state == nil:
    return CounterState(count: 0)
  if action of IncrementAction:
    result = CounterState(count: state.count + 1)
  elif action of DecrementAction:
    result = CounterState(count: state.count - 1)
  else:
    result = state

var store = newStore(counter)

store.dispatch(IncrementAction())
echo store.getState().count

store.dispatch(DecrementAction())
echo store.getState().count
