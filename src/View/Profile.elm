module View.Profile exposing (view)

import Helpers
import Html
import Model exposing (Model)
import Msg exposing (Msg(Logout))
import Router
import Types


view : Model -> Router.ProfileRoute -> Html.Html Msg
view model route =
    let
        contents =
            case model.auth of
                Types.Authenticated _ user ->
                    [ menu route, body route user ]

                Types.Authenticating ->
                    [ Helpers.loading ]

                Types.Anonymous ->
                    [ Helpers.notAuthed ]
    in
        Html.div [] ((header model) :: contents)


header : Model -> Html.Html Msg
header model =
    let
        logout =
            case model.auth of
                Types.Authenticated token _ ->
                    Helpers.evButton (Logout token) "Logout"

                _ ->
                    Html.span [] []
    in
        Html.div []
            [ Helpers.navButton Router.Home "Back"
            , logout
            , Html.h1 [] [ Html.text "Profile" ]
            ]


menu : Router.ProfileRoute -> Html.Html Msg
menu route =
    Html.ul []
        [ Html.li [] [ Helpers.navButton (Router.Profile Router.Tests) "Tests" ]
        , Html.li [] [ Helpers.navButton (Router.Profile Router.Settings) "Settings" ]
        , Html.li [] [ Helpers.navButton (Router.Profile Router.Emails) "Emails" ]
        ]


body : Router.ProfileRoute -> Types.User -> Html.Html Msg
body route user =
    case route of
        Router.Tests ->
            Html.text "Tests"

        Router.Settings ->
            Html.text "Settings"

        Router.Emails ->
            Html.text "Emails"
