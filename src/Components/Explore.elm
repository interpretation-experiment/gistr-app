module Components.Explore exposing (component, translator)

import Html exposing (..)
import Html.Events exposing (..)
import RouteUrl.Builder as Builder
import Components.Explore.Types exposing (..)
import Components.Explore.Routes exposing (..)
import Wiring exposing (Component)
import Services.Account.Types as AccountTypes


-- MODEL


init : ( Model, Cmd Msg )
init =
    ( Empty, Cmd.none )



-- MESSAGES


translator : TranslationDictionary t parentMsg -> Translator parentMsg
translator dictionary msg =
    case msg of
        OutNavigateBack ->
            dictionary.onNavigateBack



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg, Maybe OutMsg )
update msg model =
    case msg of
        RequestNavigateBack ->
            ( model, Cmd.none, Just OutNavigateBack )

        NavigateTo route ->
            ( model, Cmd.none, Nothing )



-- VIEW


view : AccountTypes.Model -> Model -> Html Msg
view account model =
    div []
        [ button [ onClick RequestNavigateBack ] [ text "Back" ]
        , h2 [] [ text "Explore" ]
        , p [] [ text "Explore this experiment" ]
        ]



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
