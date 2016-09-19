module View.Home exposing (view)

import Helpers
import Html
import Model exposing (Model)
import Msg exposing (Msg)
import Router
import Types


view : Model -> Html.Html Msg
view model =
    Html.div [] [ header, body model ]


header : Html.Html msg
header =
    Html.h1 [] [ Html.text "Home" ]


body : Model -> Html.Html Msg
body model =
    case model.auth of
        Types.Anonymous ->
            Html.div []
                [ Helpers.navButton Router.About "About"
                , Helpers.navButton Router.Login "Login"
                ]

        Types.Authenticating ->
            Html.div [] [ Helpers.loading ]

        Types.Authenticated _ user ->
            Html.div []
                [ Html.p [] [ Html.text ("Howdy, " ++ user.username) ]
                , Html.div []
                    [ Helpers.navButton Router.About "About"
                    , Helpers.navButton (Router.Profile Router.Tests) "Profile"
                    ]
                ]
