module Experiment.Msg exposing (Msg(..))

import Clock
import Intro
import Random
import Types


type Msg
    = NoOp
    | UpdateProfile Types.Profile
    | ClockMsg Clock.Msg
      -- INSTRUCTIONS
    | InstructionsMsg Intro.Msg
    | InstructionsStart
    | InstructionsQuit Int
    | InstructionsDone
      -- TRIAL
    | LoadTrial
    | LoadedTrial ( List Types.Sentence, Types.Sentence )
    | TrialTask
    | TrialWrite
    | TrialTimeout
    | TrialPause
    | WriteInput String
    | WriteFail Types.Error
    | WriteSubmit String
    | TrialSuccess Types.Profile
