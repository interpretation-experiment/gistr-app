module View.Home exposing (view)

import Helpers
import Html
import Model exposing (Model)
import Msg exposing (Msg)
import Router
import Styles exposing (class, classList, id)
import Types


view : Model -> List (Html.Html Msg)
view model =
    [ Html.header [] (header model)
    , Html.div [] [ Html.div [ class [ Styles.Narrow ] ] (body model) ]
    , Html.footer [] (footer model)
    ]


header : Model -> List (Html.Html msg)
header model =
    case model.auth of
        Types.Anonymous ->
            []

        Types.Authenticating ->
            []

        Types.Authenticated { user } ->
            [ Html.div
                [ class [ Styles.Meta ] ]
                [ Html.text ("Howdy, " ++ user.username) ]
            ]


body : Model -> List (Html.Html Msg)
body model =
    (Html.h1 [] [ Html.text "Home" ]) :: (buttons model)


buttons : Model -> List (Html.Html Msg)
buttons model =
    case model.auth of
        Types.Anonymous ->
            [ Helpers.navButton Router.About "About"
            , Helpers.navButton (Router.Login Nothing) "Sign in"
            , Helpers.navButton (Router.Register Nothing) "Sign up"
            ]

        Types.Authenticating ->
            [ Helpers.loading ]

        Types.Authenticated _ ->
            [ Helpers.navButton Router.About "About"
            , Helpers.navButton Router.Experiment "Pass the experiment"
            , Helpers.navButton (Router.Profile Router.Dashboard) "Profile"
            ]


footer : Model -> List (Html.Html Msg)
footer model =
    [ Html.text "Some buttons here" ]
