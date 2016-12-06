module View exposing (view)

import Auth.View.Login
import Auth.View.Prolific
import Auth.View.Recover
import Auth.View.Register
import Auth.View.Reset
import Experiment.View
import Helpers
import Home.View
import Html
import Model exposing (Model)
import Msg exposing (Msg)
import Notification
import Profile.View
import Router
import Styles exposing (class, classList, id)
import Types
import View.About
import View.Error


notificationConfig : Notification.ViewConfig ( String, Html.Html Msg, Types.Notification ) Msg
notificationConfig =
    Notification.viewConfig Msg.Notify notificationTemplate


notificationTemplate : ( String, Html.Html Msg, Types.Notification ) -> Msg -> Html.Html Msg
notificationTemplate ( title, content, tipe ) dismiss =
    let
        style =
            case tipe of
                Types.Info ->
                    Styles.InfoNotification

                Types.Warning ->
                    Styles.WarningNotification

                Types.Success ->
                    Styles.SuccessNotification
    in
        Html.div [ class [ style ] ]
            [ Helpers.evIconButton [] dismiss "close"
            , Html.p [] [ Html.strong [] [ Html.text title ] ]
            , Html.div [] [ content ]
            ]


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
            Home.View.view Msg.HomeMsg model

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
