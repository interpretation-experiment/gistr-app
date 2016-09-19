module View exposing (view)

import Html
import Html.Events
import Model exposing (Model)
import Msg exposing (Msg(..))
import Router


view : Model -> Html.Html Msg
view model =
    case model.route of
        Router.Home ->
            Html.div []
                [ Html.h1 [] [ Html.text "Home" ]
                , navButton Router.About "About"
                , navButton (Router.Profile Router.Tests) "Profile"
                ]

        Router.About ->
            Html.div []
                [ navButton Router.Home "Back"
                , Html.h1 [] [ Html.text "About" ]
                ]

        Router.Profile profileRoute ->
            Html.div []
                [ navButton Router.Home "Back"
                , Html.h1 [] [ Html.text "Profile" ]
                , profileMenu profileRoute
                , profileView profileRoute
                ]


navButton : Router.Route -> String -> Html.Html Msg
navButton route text =
    Html.button [ Html.Events.onClick (NavigateTo route) ] [ Html.text text ]


profileMenu : Router.ProfileRoute -> Html.Html Msg
profileMenu profileRoute =
    Html.ul []
        [ Html.li [] [ navButton (Router.Profile Router.Tests) "Tests" ]
        , Html.li [] [ navButton (Router.Profile Router.Settings) "Settings" ]
        , Html.li [] [ navButton (Router.Profile Router.Emails) "Emails" ]
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
