module Main exposing (..)

import Dict
import LocalStorage
import Maybe.Extra exposing ((?))
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



-- URL UPDATE


urlUpdate : ( String, Maybe Router.Route ) -> Model -> ( Model, Cmd Msg )
urlUpdate ( requestedUrl, maybeRoute ) model =
    let
        route =
            maybeRoute ? model.route

        url =
            Router.toUrl route

        _ =
            Debug.log "url update" requestedUrl
    in
        if route /= model.route then
            Update.update (Msg.NavigateTo route) model
        else if url /= requestedUrl then
            ( model, Navigation.modifyUrl url )
        else
            model ! []



-- SUBSCRIPTIONS


localStorageTags : Dict.Dict String (Maybe String -> Msg)
localStorageTags =
    Dict.fromList [ ( LocalStorage.token, Msg.GotLocalToken ) ]


subscriptions : Model -> Sub Msg
subscriptions model =
    LocalStorage.subscribe localStorageTags Msg.NoOp



-- INIT


init : ( String, Maybe Router.Route ) -> ( Model, Cmd Msg )
init ( url, maybeRoute ) =
    let
        ( model, cmd ) =
            urlUpdate ( url, maybeRoute ) (Model.initialModel Router.Home)
    in
        model ! [ cmd, LocalStorage.tokenGet ]
