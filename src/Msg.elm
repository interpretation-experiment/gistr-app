module Msg exposing (Msg(..))

import Animation
import Auth.Msg as Auth
import Instructions
import Profile.Msg as Profile
import Router
import Store
import Types


type Msg
    = NoOp
    | Animate Animation.Msg
      -- NAVIGATION
    | NavigateTo Router.Route
    | Error Types.Error
      -- AUTH
    | AuthMsg Auth.Msg
      -- PROFILE
    | ProfileMsg Profile.Msg
      -- STORE
    | GotStoreItem Store.Item
    | GotMeta Types.Meta
      -- REFORMULATIONS EXPERIMENT
    | ReformulationInstructions Instructions.Msg
    | ReformulationInstructionsRestart
    | ReformulationInstructionsQuit Int
    | ReformulationInstructionsDone
    | ReformulationExpStart
