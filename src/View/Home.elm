module View.Home exposing (view)

import Helpers
import Html
import Lifecycle
import Model exposing (Model)
import Msg exposing (Msg)
import Router
import Strings
import Styles exposing (class, classList, id)
import Types


view : Model -> List (Html.Html Msg)
view model =
    [ Html.header [] (header model)
    , Html.main_ [] [ Html.div [ class [ Styles.SuperNarrow ] ] (body model) ]
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
                [ class [ Styles.Meta, Styles.FlexCenter ] ]
                [ Html.span []
                    [ Html.text "Howdy, "
                    , Html.strong [] [ Html.text user.username ]
                    ]
                , Helpers.avatar user (Router.Profile Router.Dashboard)
                ]
            ]


body : Model -> List (Html.Html Msg)
body model =
    [ Html.div []
        [ Html.div [ id Styles.Greeting ]
            [ Html.h1 [] [ Html.text "Gistr" ]
            , Html.p []
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
                [ Helpers.navButton
                    [ class [ Styles.Btn, Styles.BtnPrimary ] ]
                    (Router.Register Nothing)
                    "Pass the experiment"
                , Helpers.navButton
                    [ class [ Styles.Btn ] ]
                    (Router.Login Nothing)
                    "Sign in"
                ]

        Types.Authenticating ->
            Helpers.loading Styles.Big

        Types.Authenticated _ ->
            Html.div []
                [ Helpers.navButton
                    [ class [ Styles.Btn, Styles.BtnPrimary ] ]
                    Router.Experiment
                    "Pass the experiment"
                ]


footer : Model -> List (Html.Html Msg)
footer model =
    let
        -- TODO: intro icon
        devs =
            Helpers.hrefIcon
                [ class [ Styles.Small ], Helpers.tooltip "Email the developers" ]
                "mailto:sl@mehho.net"
                "envelope"

        about =
            Helpers.navIcon
                [ class [ Styles.Small ], Helpers.tooltip "About Gistr" ]
                Router.About
                "info-circle"

        twitter =
            Helpers.hrefIcon
                [ class [ Styles.Small ], Helpers.tooltip "Twitter" ]
                "https://twitter.com/gistrexp"
                "twitter"

        github =
            Helpers.hrefIcon
                [ class [ Styles.Small ], Helpers.tooltip "GitHub" ]
                "https://github.com/interpretation-experiment/gistr-app"
                "github"

        icons =
            case model.auth of
                Types.Anonymous ->
                    [ devs, about ]

                Types.Authenticating ->
                    [ devs, about ]

                Types.Authenticated { user, meta } ->
                    if user.isStaff then
                        -- TODO: and intro icon
                        [ devs, about, twitter, github ]
                    else
                        case Lifecycle.state meta user.profile of
                            Lifecycle.Training _ ->
                                -- TODO: and intro icon
                                [ devs, about ]

                            Lifecycle.Experiment _ ->
                                -- TODO: and intro icon
                                [ devs, about ]

                            Lifecycle.Done ->
                                -- TODO: and intro icon
                                [ devs, about, twitter, github ]
    in
        [ Html.div [] icons ]
