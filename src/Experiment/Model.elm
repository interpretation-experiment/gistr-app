module Experiment.Model
    exposing
        ( SeriesState(..)
        , State(..)
        , TrialState(..)
        , instructionsState
        )

import Experiment.Instructions as Instructions
import Intro


instructionsState : State a -> Intro.State Instructions.Instruction
instructionsState state =
    case state of
        Instructions instructionsState ->
            instructionsState

        _ ->
            Intro.hide


type State a
    = Instructions (Intro.State Instructions.Instruction)
    | Training (SeriesState a)
    | Exping (SeriesState a)


type SeriesState a
    = Trial a TrialState
    | Pause
    | Finished


type TrialState
    = Reading
    | Tasking
    | Writing
