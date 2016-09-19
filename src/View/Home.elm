module View.Home exposing (view)

import Helpers
import Html
import Model exposing (Model)
import Msg exposing (Msg)
import Router


view : Model -> Html.Html Msg
view model =
    Html.div []
        [ Html.h1 [] [ Html.text "Home" ]
        , Helpers.navButton Router.About "About"
        , Helpers.navButton (Router.Profile Router.Tests) "Profile"
        ]
