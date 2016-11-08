module Experiment.Msg exposing (Msg(..))

import Intro


type Msg
    = -- Run (List a)
      -- INSTRUCTIONS
      InstructionsMsg Intro.Msg
    | InstructionsStart
    | InstructionsQuit Int
    | InstructionsDone
      -- TRIAL
    | StartTrial
