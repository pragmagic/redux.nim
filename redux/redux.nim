type
  Action* = ref object of RootObj
  Reducer* [S] = proc (state: S = nil; action: Action = nil): S
  Subscriber* [S] = proc (state: S)
  Store [S] = ref object {.requiresInit.}
    state: S
    reducer: Reducer[S]
    subscribers: seq[Subscriber[S]]

proc newStore*[S](reducer: Reducer[S]): Store[S] =
  Store[S](
    state: reducer(),
    reducer: reducer,
    subscribers: @[]
  )

proc getState*[S](store: Store[S]): S =
  store.state

proc subscribe*[S](store: Store[S], subscriber: Subscriber[S]) =
  store.subscribers.add(subscriber)

proc unsubscribe*[S](store: Store[S], subscriber: Subscriber[S]) =
  for index, s in pairs(store.subscribers):
    if s == subscriber:
      store.subscribers.del(index)
      break

proc dispatch*(store: Store, action: Action) =
  store.state = store.reducer(state=store.state, action=action)
  for subscriber in store.subscribers:
    subscriber(store.state)
