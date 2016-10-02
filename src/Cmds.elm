module Cmds exposing (cmdsForRoute)

import Api
import Model exposing (Model)
import Msg exposing (Msg)
import Router
import Store
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

        Router.Profile (Router.Dashboard) ->
            authenticatedOrIgnore model <|
                \auth ->
                    case auth.user.profile.wordSpanId of
                        Nothing ->
                            []

                        Just id ->
                            [ Task.perform
                                Msg.Error
                                (Msg.GotStoreItem << Store.WordSpan)
                                (Api.fetch model.store.wordSpans id auth)
                            ]

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
