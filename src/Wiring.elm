module Wiring exposing (UpdateConfig)

import Msg exposing (Msg)
import Model exposing (Model)


type alias UpdateConfig msg =
    { lift : msg -> Msg
    , appUpdate : Msg -> Model -> ( Model, Cmd Msg )
    }
