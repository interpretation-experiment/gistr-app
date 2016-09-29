module Cmds exposing (cmdsForRoute)

import Api
import Msg exposing (Msg)
import Model exposing (Model)
import Router
import Task
import Types


cmdsForRoute : Model -> Router.Route -> List (Cmd Msg)
cmdsForRoute model route =
    case route of
        Router.Profile (Router.Confirm key) ->
            authenticatedOrIgnore model <|
                \auth ->
                    case model.emailConfirmation of
                        Model.SendingConfirmation ->
                            [ Task.perform
                                Msg.EmailConfirmationFail
                                Msg.EmailConfirmationSuccess
                                (Api.confirmEmail key auth)
                            ]

                        _ ->
                            []

        _ ->
            []



-- CMD HELPERS


authenticatedOrIgnore :
    Model
    -> (Types.Auth -> List (Cmd Msg))
    -> List (Cmd Msg)
authenticatedOrIgnore model authFunc =
    case model.auth of
        Types.Authenticated auth ->
            authFunc auth

        _ ->
            []
