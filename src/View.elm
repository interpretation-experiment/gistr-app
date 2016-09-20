module View exposing (view)

import Html
import Model exposing (Model)
import Msg exposing (Msg)
import Router
import View.About
import View.Home
import View.Login
import View.Profile
import View.Recover
import View.Reset


view : Model -> Html.Html Msg
view model =
    case model.route of
        Router.Home ->
            View.Home.view model

        Router.About ->
            View.About.view model

        Router.Login ->
            View.Login.view model

        Router.Recover ->
            View.Recover.view model

        Router.Reset ->
            View.Reset.view model

        Router.Profile profileRoute ->
            View.Profile.view model profileRoute
