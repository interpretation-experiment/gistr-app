module View exposing (view)

import Admin.View
import Auth.View.Login
import Auth.View.Prolific
import Auth.View.Recover
import Auth.View.Register
import Auth.View.Reset
import Comment.View
import Experiment.View
import Explore.View
import Home.View
import Html
import Model exposing (Model)
import Msg exposing (Msg)
import Notification
import Profile.View
import Router
import Styles exposing (class, classList, id)
import View.About
import View.Error
import View.Notification


view : Model -> Html.Html Msg
view model =
    Html.div []
        [ Notification.view View.Notification.config model.notifications
        , Comment.View.view Msg.CommentMsg model
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

        Router.Admin ->
            Admin.View.view Msg.AdminMsg model

        Router.Explore exploreRoute ->
            Explore.View.view model exploreRoute
