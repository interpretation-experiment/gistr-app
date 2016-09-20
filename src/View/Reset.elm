module View.Reset exposing (view)

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
        [ Helpers.navButton Router.Login "Back"
        , Html.h1 [] [ Html.text "Set new password" ]
        ]


body : Model -> Html.Html Msg
body model =
    Html.div [] []
