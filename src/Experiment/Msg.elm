module Experiment.Msg exposing (Msg(..))

import Intro


type Msg
    = -- INSTRUCTIONS
      InstructionsMsg Intro.Msg
    | InstructionsRestart
    | InstructionsQuit Int
    | InstructionsDone
      -- EXPERIMENT
    | Start
