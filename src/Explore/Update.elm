module Explore.Update exposing (update)

import Explore.Model exposing (Model)
import Explore.Msg exposing (Msg(..))
import Explore.Router
import Msg as AppMsg
import Router
import Types


update :
    (Msg -> AppMsg.Msg)
    -> Msg
    -> Model
    -> ( Model, Cmd AppMsg.Msg, List AppMsg.Msg )
update lift msg model =
    case msg of
        TreesResult (Ok page) ->
            let
                trees =
                    Just { lastTotalTrees = page.totalItems, maybeTrees = Just page.items }
            in
                ( { model | trees = trees }
                , Cmd.none
                , []
                )

        TreesResult (Err error) ->
            ( model
            , Cmd.none
            , [ AppMsg.Error error ]
            )

        TreesViewConfigInput (Ok config) ->
            let
                loadingTrees =
                    Maybe.map (\trees -> { trees | maybeTrees = Nothing }) model.trees
            in
                ( { model | trees = loadingTrees }
                , Cmd.none
                , [ AppMsg.NavigateToNoflush <|
                        Router.Explore <|
                            Router.Trees <|
                                Explore.Router.params config
                  ]
                )

        TreesViewConfigInput (Err error) ->
            ( model
            , Cmd.none
            , [ AppMsg.Error <| Types.Unrecoverable error ]
            )
