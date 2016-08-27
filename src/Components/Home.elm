module Components.Home exposing (component, translator)

import Html exposing (..)
import Html.Events exposing (..)
import RouteUrl.Builder as Builder
import Components.Home.Types exposing (..)
import Components.Home.Routes exposing (..)
import Wiring exposing (Component)
import App.Routes as AppRoutes
import Services.Account.Types as AccountTypes


-- MODEL


init : ( Model, Cmd Msg )
init =
    ( Empty, Cmd.none )



-- MESSAGES


translator : TranslationDictionary t parentMsg -> Translator parentMsg
translator dictionary msg =
    case msg of
        OutNavigateTo route ->
            dictionary.onNavigateTo route

        OutLogout ->
            dictionary.onLogout



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg, Maybe OutMsg )
update msg model =
    case msg of
        RequestNavigateTo route ->
            ( model, Cmd.none, Just (OutNavigateTo route) )

        RequestLogout ->
            ( model, Cmd.none, Just OutLogout )

        NavigateTo IndexRoute ->
            ( model, Cmd.none, Nothing )



-- VIEW


view : AccountTypes.Model -> Model -> Html Msg
view account model =
    let
        body =
            case account of
                AccountTypes.Anonymous _ ->
                    [ linkTo (AppRoutes.LoginRoute Nothing) "login"
                    , linkTo (AppRoutes.AboutRoute Nothing) "about"
                    ]

                AccountTypes.Authenticating _ ->
                    [ p [] [ text "Loading..." ] ]

                AccountTypes.Authenticated _ user ->
                    [ p [] [ text ("Howdy, " ++ user.username) ]
                    , linkTo (AppRoutes.PlayRoute Nothing) "play"
                    , linkTo (AppRoutes.ExploreRoute Nothing) "explore"
                    , linkTo (AppRoutes.AboutRoute Nothing) "about"
                    , linkTo (AppRoutes.ProfileRoute Nothing) "profile"
                    , button [ onClick RequestLogout ] [ text "Log out" ]
                    ]
    in
        div []
            [ h2 [] [ text "Home" ]
            , div [] body
            ]


linkTo : AppRoutes.Route -> String -> Html Msg
linkTo route title =
    button [ onClick (RequestNavigateTo route) ] [ text title ]



-- ROUTING


model2builder : Model -> Maybe Builder.Builder
model2builder model =
    Builder.builder
        |> Builder.replacePath []
        |> Just


builder2routeMessages : Builder.Builder -> ( Route, List Msg )
builder2routeMessages builder =
    ( IndexRoute, [] )



-- COMPONENT


component =
    Component init update view (always Sub.none) NavigateTo model2builder builder2routeMessages
