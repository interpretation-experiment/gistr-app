module Main exposing (..)

import Auth.Msg as AuthMsg
import Dict
import Experiment.Subscription as ExpSub
import Home.Msg as HomeMsg
import Intro
import LocalStorage
import Model exposing (Model)
import Msg exposing (Msg)
import Navigation
import Router
import Update
import View


main : Program Never Model Msg
main =
    Navigation.program (uncurry Msg.UrlUpdate << Router.parse)
        { init = init
        , view = View.view
        , update = Update.update
        , subscriptions = subscriptions
        }



-- SUBSCRIPTIONS


localStorageTags : Dict.Dict String (Maybe String -> Msg)
localStorageTags =
    Dict.fromList [ ( LocalStorage.token, Msg.AuthMsg << AuthMsg.GotLocalToken ) ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ LocalStorage.subscribe localStorageTags Msg.NoOp
        , Intro.subscription (Msg.HomeMsg << HomeMsg.InstructionsMsg) model.home
        , ExpSub.subscription Msg.ExperimentMsg model
        ]



-- INIT


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    -- Don't trigger any navigation (-> url update and/or redirection) due to
    -- the initial url, just wait for the tokenGet subscription to return a
    -- GotLocalToken, and that will trigger a navigation either way. Doing
    -- otherwise creates two competing navigation events (so url updates and/or
    -- redirections): the initial one, and the one from GotLocalToken.
    let
        ( _, route ) =
            Router.parse location

        -- Don't let the user load the /error route initially
        nonErrorRoute =
            if route == Router.Error then
                Router.Home
            else
                route
    in
        Model.initialModel nonErrorRoute ! [ LocalStorage.tokenGet ]
