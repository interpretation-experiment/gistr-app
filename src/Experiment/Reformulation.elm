module Experiment.Reformulation
    exposing
        ( InstructionsState(..)
        , SeriesState(..)
        , TrialState(..)
        )


type InstructionsState
    = A
    | B
    | C


type SeriesState a
    = Trial a TrialState
    | Pause
    | Finished


type TrialState
    = Reading
    | Tasking
    | Writing
