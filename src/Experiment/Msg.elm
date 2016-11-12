module Experiment.Msg exposing (Msg(..))

import Clock
import Intro
import Random
import Types


type Msg
    = UpdateProfile Types.Profile
    | ClockMsg Clock.Msg
      -- EXPERIMENT STATE
    | Preload Random.Seed
    | Run (List Types.Sentence)
    | Error
      -- INSTRUCTIONS
    | InstructionsMsg Intro.Msg
    | InstructionsStart
    | InstructionsQuit Int
    | InstructionsDone
      -- TRIAL
    | LoadTrial
    | LoadedTrial Types.Sentence
    | TrialTask
    | TrialWrite
    | TrialTimeout
    | WriteInput String
    | WriteFail Types.Error
    | WriteSubmit String
    | TrialSuccess Types.Profile
      -- OTHER RUN STATE
    | Pause
