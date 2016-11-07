module View exposing (view)

import Html
import Model exposing (Model)
import Msg exposing (Msg)
import Router
import View.About
import View.Error
import View.Experiment
import View.Home
import View.Login
import View.Profile
import View.Prolific
import View.Recover
import View.Register
import View.Reset


view : Model -> Html.Html Msg
view model =
    case model.route of
        Router.Home ->
            View.Home.view model

        Router.About ->
            View.About.view model

        Router.Login _ ->
            View.Login.view model

        Router.Recover ->
            View.Recover.view model

        Router.Reset tokens ->
            View.Reset.view model tokens

        Router.Register maybeProlific ->
            View.Register.view model maybeProlific

        Router.Error ->
            View.Error.view model

        Router.Prolific ->
            View.Prolific.view model

        Router.Profile profileRoute ->
            View.Profile.view model profileRoute

        Router.Experiment ->
            View.Experiment.view model
