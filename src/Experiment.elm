module Experiment exposing (State(..))


type State a b
    = Instructions a
    | Training b
    | Exping b


next : b -> State a b -> State a b
next init state =
    case state of
        Instructions _ ->
            Training init

        Training _ ->
            Exping init

        Exping _ ->
            state
