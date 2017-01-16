module Experiment.Msg exposing (Msg(..))

import Api
import Clock
import Intro
import Types


type Msg
    = NoOp
    | ClockMsg Clock.Msg
    | CtrlEnter
      -- COPY-PASTE PREVENTION
    | CopyPasteEvent
      -- INSTRUCTIONS
    | InstructionsMsg Intro.Msg
    | InstructionsStart
    | InstructionsQuit Int
    | InstructionsDone
    | InstructionsDoneResult (Api.Result Types.Profile)
      -- TRIAL
    | LoadTrial
    | LoadTrialResult (Api.Result Types.Sentence)
    | TrialTask
    | TrialWrite
    | TrialTimeout
    | TrialStandby
    | WriteInput String
    | WriteSubmit String
    | WriteResult (Api.Result Types.Profile)
