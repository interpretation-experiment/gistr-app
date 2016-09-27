module Cmds exposing (cmdsForRoute)

import Msg exposing (Msg)
import Model exposing (Model)
import Router


cmdsForRoute : Model -> Router.Route -> List (Cmd Msg)
cmdsForRoute model route =
    []
