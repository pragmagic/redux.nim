import redux

type
  UndoableState* [S] = ref object
    past: seq[S]
    present: S
    future: seq[S]
  UndoAction* = ref object of Action
  RedoAction* = ref object of Action

proc isUndoable*[S](state: UndoableState[S]): bool =
  len(state.past) > 0

proc isRedoable*[S](state: UndoableState[S]): bool =
  len(state.future) > 0

proc getPresent*[S](state: UndoableState[S]): S =
  state.present

proc undoable*[S](reducer: Reducer[S]): Reducer[UndoableState[S]] =
  let initialState = UndoableState[S](
    past: @[],
    present: reducer(),
    future: @[]
  )

  result = proc (state: UndoableState[S], action: Action): UndoableState[S] =
    if state == nil:
      result = initialState
    elif action of UndoAction:
      assert state.isUndoable()
      var past = state.past
      let previous = past[high(past)]
      past.delete(high(past))
      result = UndoableState[S](
        past: past,
        present: previous,
        future: state.present & state.future
      )
    elif action of RedoAction:
      assert state.isRedoable()
      var future = state.future
      let next = future[low(future)]
      future.delete(low(future))
      result = UndoableState[S](
        past: state.past & state.present,
        present: next,
        future: future
      )
    else:
      let present = reducer(state=state.present, action=action)
      result = UndoableState[S](
        past: state.past & state.present,
        present: present,
        future: @[]
      )
