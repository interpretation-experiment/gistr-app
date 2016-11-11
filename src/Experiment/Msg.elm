module Experiment.Msg exposing (Msg(..))

import Clock
import Intro
import Random
import Types


type Msg
    = PreloadTraining Random.Seed
    | Run (List Types.Sentence)
    | Error
    | UpdateProfile Types.Profile
    | ClockMsg Clock.Msg
      -- INSTRUCTIONS
    | InstructionsMsg Intro.Msg
    | InstructionsStart
    | InstructionsQuit Int
    | InstructionsDone
      -- TRIAL
    | StartTrial
    | TrialRead Types.Sentence
    | TrialTask
    | TrialWrite
