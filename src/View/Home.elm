module View.Home exposing (view)

import Helpers
import Html
import Model exposing (Model)
import Msg exposing (Msg)
import Router
import Strings
import Styles exposing (class, classList, id)
import Types


view : Model -> List (Html.Html Msg)
view model =
    [ Html.header [] (header model)
    , Html.div [] [ Html.div [ class [ Styles.SuperNarrow ] ] (body model) ]
    , Html.footer [] (footer model)
    ]


header : Model -> List (Html.Html Msg)
header model =
    case model.auth of
        Types.Anonymous ->
            []

        Types.Authenticating ->
            []

        Types.Authenticated { user } ->
            [ Html.div
                [ class [ Styles.Meta ] ]
                [ Html.text ("Howdy, " ++ user.username)
                , Helpers.navButton (Router.Profile Router.Dashboard) "Profile"
                ]
            ]


body : Model -> List (Html.Html Msg)
body model =
    [ Html.div []
        [ Html.div [ id Styles.Greeting ]
            [ Html.h1 [] [ Html.text "Gistr" ]
            , Html.small []
                (Strings.homeSubtitle1 ++ [ Html.br [] [] ] ++ Strings.homeSubtitle2)
            ]
        , Html.div [] Strings.homeQuestions
        , buttons model
        ]
    ]


buttons : Model -> Html.Html Msg
buttons model =
    case model.auth of
        Types.Anonymous ->
            Html.div []
                [ Helpers.navButton (Router.Login Nothing) "Sign in"
                , Helpers.navButton (Router.Register Nothing) "Sign up"
                ]

        Types.Authenticating ->
            Helpers.loading

        Types.Authenticated _ ->
            Html.div []
                [ Helpers.navButton Router.Experiment "Pass the experiment" ]


footer : Model -> List (Html.Html Msg)
footer model =
    [ Html.div []
        [ Helpers.navButton Router.About "About" ]
    ]
