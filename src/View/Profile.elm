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
                Types.Authenticated _ _ ->
                    [ menu route, body route ]

                Types.Authenticating ->
                    [ Helpers.loading ]

                Types.Anonymous ->
                    [ Html.p []
                        [ Html.text "Not signed in. "
                        , Helpers.navA (Router.Profile route |> Just |> Router.Login) "Sign in"
                        , Html.text " first!"
                        ]
                    ]
    in
        Html.div [] ((header model) :: contents)


header : Model -> Html.Html Msg
header model =
    let
        logout =
            case model.auth of
                Types.Authenticated _ _ ->
                    Helpers.evButton Logout "Logout"

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


body : Router.ProfileRoute -> Html.Html Msg
body route =
    case route of
        Router.Tests ->
            Html.text "Tests"

        Router.Settings ->
            Html.text "Settings"

        Router.Emails ->
            Html.text "Emails"
