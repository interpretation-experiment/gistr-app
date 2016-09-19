module View exposing (view)

import Html
import Model exposing (Model)
import Msg exposing (Msg)
import Router
import View.About
import View.Home
import View.Profile


view : Model -> Html.Html Msg
view model =
    case model.route of
        Router.Home ->
            View.Home.view model

        Router.About ->
            View.About.view model

        Router.Profile profileRoute ->
            View.Profile.view model profileRoute
