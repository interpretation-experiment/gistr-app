module Explore.Cmds exposing (cmdsForModel)

import Api
import Explore.Model exposing (Model)
import Explore.Msg as Msg
import Explore.Router
import Router
import Task
import Types


cmdsForModel :
    (Msg.Msg -> msg)
    -> Types.Auth
    -> Model
    -> Router.ExploreRoute
    -> List (Cmd msg)
cmdsForModel lift auth model route =
    case route of
        Router.Trees config ->
            let
                { page, pageSize, rootBucket } =
                    Explore.Router.viewConfig config
            in
                [ Task.attempt (lift << Msg.TreesResult) <|
                    Api.getTrees
                        auth
                        (Just { page = page, pageSize = pageSize })
                        [ ( "root_bucket", rootBucket ) ]
                ]

        Router.Tree id ->
            []
