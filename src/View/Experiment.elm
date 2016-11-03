module View.Experiment exposing (view)

import Helpers
import Html
import Model exposing (Model)
import Msg exposing (Msg)
import Router


view : Model -> Html.Html Msg
view model =
    Html.div [] [ header, body model ]


header : Html.Html Msg
header =
    Html.div []
        [ Helpers.navButton Router.Home "Back"
        , Html.h1 [] [ Html.text "Experiment" ]
        ]


body : Model -> Html.Html Msg
body model =
    Html.div [] []
