module Explore.Update exposing (update)

import Explore.Model exposing (Model)
import Explore.Msg exposing (Msg(..))
import Msg as AppMsg


update :
    (Msg -> AppMsg.Msg)
    -> Msg
    -> Model
    -> ( Model, Cmd AppMsg.Msg, List AppMsg.Msg )
update lift msg model =
    case msg of
        TreesResult (Ok trees) ->
            ( { model | trees = Just trees }
            , Cmd.none
            , []
            )

        TreesResult (Err error) ->
            ( model
            , Cmd.none
            , [ AppMsg.Error error ]
            )
