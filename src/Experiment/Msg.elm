module Experiment.Msg exposing (Msg(..))

import Intro
import Random
import Types


type Msg
    = PreloadTraining Types.Meta Random.Seed
    | Run (List Types.Sentence)
    | Error
    | UpdateProfile Types.Profile
      -- INSTRUCTIONS
    | InstructionsMsg Intro.Msg
    | InstructionsStart
    | InstructionsQuit Int
    | InstructionsDone
      -- TRIAL
    | StartTrial
