module Main exposing (..)

import Maybe.Extra exposing ((?))
import Model exposing (Model)
import Msg exposing (Msg)
import Navigation
import Router
import Subscriptions
import Update
import View


main : Program Never
main =
    Navigation.program (Navigation.makeParser Router.locationParser)
        { init = init
        , view = View.view
        , update = Update.update
        , urlUpdate = urlUpdate
        , subscriptions = Subscriptions.subscriptions
        }



-- URL UPDATE


urlUpdate : ( String, Maybe Router.Route ) -> Model -> ( Model, Cmd Msg )
urlUpdate ( url, maybeRoute ) model =
    let
        route =
            maybeRoute ? model.route

        routeUrl =
            Router.toUrl route
    in
        if url /= routeUrl then
            model ! [ Navigation.modifyUrl (Debug.log "corrected url" routeUrl) ]
        else
            Model.emptyForms { model | route = route } ! []



-- INIT


init : ( String, Maybe Router.Route ) -> ( Model, Cmd Msg )
init ( url, maybeRoute ) =
    let
        ( model, cmd ) =
            urlUpdate ( url, maybeRoute ) (Model.initialModel Router.Home)
    in
        model ! [ cmd, Subscriptions.localTokenGet ]
