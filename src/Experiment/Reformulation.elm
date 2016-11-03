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


type SeriesState
    = Trial TrialState
    | Pause
    | Finished


type TrialState
    = Reading
    | Tasking
    | Writing
