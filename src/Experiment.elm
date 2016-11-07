module Experiment
    exposing
        ( State(..)
        , instructionsState
        )

import Instructions


instructionsState : State a b -> Instructions.State a
instructionsState state =
    case state of
        Instructions instructionsState ->
            instructionsState

        _ ->
            Instructions.hide


type State a b
    = Instructions (Instructions.State a)
    | Training b
    | Exping b
