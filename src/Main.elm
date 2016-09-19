module Main exposing (..)

import Model exposing (Model)
import Msg exposing (Msg)
import Navigation
import Router
import Update
import View


main : Program Never
main =
    Navigation.program (Navigation.makeParser Router.locationParser)
        { init = init
        , view = View.view
        , update = Update.update
        , urlUpdate = urlUpdate
        , subscriptions = subscriptions
        }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- URL UPDATE


urlUpdate : Maybe Router.Route -> Model -> ( Model, Cmd Msg )
urlUpdate maybeRoute model =
    case (Debug.log "route" maybeRoute) of
        Just route ->
            { model | route = route } ! []

        Nothing ->
            model ! [ Navigation.modifyUrl (Router.toUrl model.route) ]



-- INIT


init : Maybe Router.Route -> ( Model, Cmd Msg )
init maybeRoute =
    urlUpdate maybeRoute (Model Router.Home)
