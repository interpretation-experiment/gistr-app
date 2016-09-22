module View.Profile exposing (view)

import Helpers
import Html
import Model exposing (Model)
import Msg exposing (Msg(Logout))
import Router


view : Model -> Router.ProfileRoute -> Html.Html Msg
view model route =
    Html.div [] [ header, menu route, body route ]


header : Html.Html Msg
header =
    Html.div []
        [ Helpers.navButton Router.Home "Back"
        , Helpers.evButton Logout "Logout"
        , Html.h1 [] [ Html.text "Profile" ]
        ]


menu : Router.ProfileRoute -> Html.Html Msg
menu route =
    Html.ul []
        [ Html.li [] [ Helpers.navButton (Router.Profile Router.Tests) "Tests" ]
        , Html.li [] [ Helpers.navButton (Router.Profile Router.Settings) "Settings" ]
        , Html.li [] [ Helpers.navButton (Router.Profile Router.Emails) "Emails" ]
        ]


body : Router.ProfileRoute -> Html.Html Msg
body route =
    case route of
        Router.Tests ->
            Html.text "Tests"

        Router.Settings ->
            Html.text "Settings"

        Router.Emails ->
            Html.text "Emails"
