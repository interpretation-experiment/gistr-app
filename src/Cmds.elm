module Cmds exposing (cmdsForRoute)

import Api
import Experiment.Msg as ExperimentMsg
import Lifecycle
import Model exposing (Model)
import Msg exposing (Msg)
import Profile.Msg as ProfileMsg
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
                            [ Task.attempt
                                (Msg.ProfileMsg << ProfileMsg.ConfirmEmailResult)
                                (Api.confirmEmail auth key)
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
                            [ Task.attempt Msg.WordSpanResult (Api.getWordSpan auth id) ]

        Router.Experiment ->
            authenticatedOrIgnore model <|
                \auth ->
                    if
                        (not auth.user.profile.introducedExpPlay
                            && Lifecycle.stateIsCompletable auth.meta auth.user.profile
                        )
                    then
                        [ Task.perform
                            (always <| Msg.ExperimentMsg ExperimentMsg.InstructionsStart)
                            (Task.succeed ())
                        ]
                    else
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
