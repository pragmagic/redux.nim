import ../redux/redux

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
