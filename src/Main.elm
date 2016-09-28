module Main exposing (..)

import Dict
import Helpers exposing ((!!))
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
urlUpdate ( newUrl, maybeRoute ) model =
    let
        modelUrl =
            Router.toUrl model.route
    in
        if (Debug.log "url" newUrl) /= modelUrl then
            -- URL has changed, do something about it
            let
                ( finalModel, navigationCmd ) =
                    Helpers.navigateTo model (maybeRoute ? model.route)

                finalRoute =
                    finalModel.route

                finalUrl =
                    Router.toUrl finalRoute
            in
                if finalRoute /= model.route then
                    -- Update the model and return corresponding commands,
                    -- and also fix the browser's url if necessary.
                    ( finalModel, navigationCmd )
                        !! (if newUrl /= finalUrl then
                                [ Navigation.modifyUrl (Debug.log "url correction" finalUrl) ]
                            else
                                []
                           )
                else
                    -- Then necessarily newUrl /= finalUrl. So don't update the model,
                    -- but fix the browser's url.
                    model ! [ Navigation.modifyUrl (Debug.log "url correction" finalUrl) ]
        else
            -- URL hasn't changed, do nothing
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
    -- Don't trigger any navigation (-> url update and/or redirection) due to
    -- the initial url, just wait for the tokenGet subscription to return a
    -- GotLocalToken, and that will trigger a navigation either way. Doing
    -- otherwise creates two competing navigation events (so url updates and/or
    -- redirections): the initial one, and the one from GotLocalToken.
    Model.initialModel (maybeRoute ? Router.Home) ! [ LocalStorage.tokenGet ]
