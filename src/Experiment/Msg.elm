module Experiment.Msg exposing (Msg(..))

import Api
import Clock
import Intro
import Types


type Msg
    = NoOp
    | ClockMsg Clock.Msg
      -- INSTRUCTIONS
    | InstructionsMsg Intro.Msg
    | InstructionsStart
    | InstructionsQuit Int
    | InstructionsDone
    | InstructionsDoneResult (Api.Result Types.Profile)
      -- TRIAL
    | LoadTrial
    | LoadTrialResult (Api.Result ( List Types.Sentence, Types.Sentence ))
    | TrialTask
    | TrialWrite
    | TrialTimeout
    | TrialPause
    | WriteInput String
    | WriteSubmit String
    | WriteResult (Api.Result Types.Profile)
