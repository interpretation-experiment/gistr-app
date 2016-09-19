module View.About exposing (view)

import Helpers
import Html
import Model exposing (Model)
import Msg exposing (Msg)
import Router


view : Model -> Html.Html Msg
view model =
    Html.div []
        [ Helpers.navButton Router.Home "Back"
        , Html.h1 [] [ Html.text "About" ]
        ]
