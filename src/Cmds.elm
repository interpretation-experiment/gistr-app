module Cmds exposing (cmdsForRoute)

import Api
import Experiment.Msg as ExperimentMsg
import Model exposing (Model)
import Msg exposing (Msg)
import Profile.Msg as ProfileMsg
import Random
import Router
import Store
import Task
import Time
import Types


cmdsForRoute : Model -> Router.Route -> List (Cmd Msg)
cmdsForRoute model route =
    case route of
        Router.Profile profileRoute ->
            authenticatedOrIgnore model <|
                \auth ->
                    case profileRoute of
                        Router.Confirm key ->
                            case model.emailConfirmation of
                                Model.SendingConfirmation ->
                                    [ Task.perform
                                        (Msg.ProfileMsg << ProfileMsg.EmailConfirmationFail)
                                        (Msg.ProfileMsg << ProfileMsg.EmailConfirmationSuccess)
                                        (Api.confirmEmail key auth)
                                    ]

                                _ ->
                                    []

                        Router.Dashboard ->
                            case auth.user.profile.wordSpanId of
                                Nothing ->
                                    []

                                Just id ->
                                    [ Task.perform
                                        Msg.Error
                                        (Msg.GotStoreItem << Store.WordSpan)
                                        (Api.fetch model.store.wordSpans id auth)
                                    ]

                        Router.Questionnaire ->
                            [ Task.perform Msg.Error Msg.GotMeta (fetchMeta model) ]

                        _ ->
                            []

        Router.Experiment ->
            let
                getSeed =
                    Time.now
                        |> Task.map (Random.initialSeed << round << Time.inMilliseconds)
            in
                [ Task.map2 ExperimentMsg.PreloadTraining (fetchMeta model) getSeed
                    |> Task.perform Msg.Error Msg.ExperimentMsg
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


fetchMeta : Model -> Task.Task Types.Error Types.Meta
fetchMeta model =
    case model.store.meta of
        Nothing ->
            Api.fetchMeta

        Just meta ->
            Task.succeed meta
