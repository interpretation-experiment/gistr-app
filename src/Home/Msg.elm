module Home.Msg exposing (Msg(..))

import Api
import Intro
import Types


type Msg
    = InstructionsMsg Intro.Msg
    | InstructionsStart
    | InstructionsQuit Int
    | InstructionsDone
    | InstructionsDoneResult (Api.Result Types.Profile)
