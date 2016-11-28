module View exposing (view)

import Auth.View.Login
import Auth.View.Prolific
import Auth.View.Recover
import Auth.View.Register
import Auth.View.Reset
import Experiment.View
import Html
import Model exposing (Model)
import Msg exposing (Msg)
import Notification
import Profile.View
import Router
import Styles exposing (class, classList, id)
import View.About
import View.Error
import View.Home


notificationConfig : Notification.ViewConfig String Msg
notificationConfig =
    Notification.viewConfig Msg.Notify (\s -> Html.p [] [ Html.text s ])


view : Model -> Html.Html Msg
view model =
    Html.div []
        [ Notification.view notificationConfig model.notifications
        , Html.div [ id Styles.Page ] (routeView model)
        ]


routeView : Model -> List (Html.Html Msg)
routeView model =
    case model.route of
        Router.Home ->
            View.Home.view model

        Router.About ->
            View.About.view model

        Router.Error ->
            View.Error.view model

        Router.Login _ ->
            Auth.View.Login.view Msg.AuthMsg model

        Router.Recover ->
            Auth.View.Recover.view Msg.AuthMsg model

        Router.Reset tokens ->
            Auth.View.Reset.view Msg.AuthMsg model tokens

        Router.Register maybeProlific ->
            Auth.View.Register.view Msg.AuthMsg model maybeProlific

        Router.Prolific ->
            Auth.View.Prolific.view Msg.AuthMsg model

        Router.Profile profileRoute ->
            Profile.View.view Msg.ProfileMsg model profileRoute

        Router.Experiment ->
            Experiment.View.view Msg.ExperimentMsg model
