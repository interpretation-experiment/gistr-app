module View.Profile exposing (view)

import Helpers
import Html
import Model exposing (Model)
import Msg exposing (Msg)
import Router


view : Model -> Router.ProfileRoute -> Html.Html Msg
view model profileRoute =
    Html.div []
        [ Helpers.navButton Router.Home "Back"
        , Html.h1 [] [ Html.text "Profile" ]
        , profileMenu profileRoute
        , profileView profileRoute
        ]


profileMenu : Router.ProfileRoute -> Html.Html Msg
profileMenu profileRoute =
    Html.ul []
        [ Html.li [] [ Helpers.navButton (Router.Profile Router.Tests) "Tests" ]
        , Html.li [] [ Helpers.navButton (Router.Profile Router.Settings) "Settings" ]
        , Html.li [] [ Helpers.navButton (Router.Profile Router.Emails) "Emails" ]
        ]


profileView : Router.ProfileRoute -> Html.Html Msg
profileView profileRoute =
    case profileRoute of
        Router.Tests ->
            Html.text "Tests"

        Router.Settings ->
            Html.text "Settings"

        Router.Emails ->
            Html.text "Emails"
