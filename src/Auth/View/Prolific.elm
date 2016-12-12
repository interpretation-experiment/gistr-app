module Auth.View.Prolific exposing (view)

import Auth.Msg exposing (Msg(..))
import Feedback
import Form
import Helpers
import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Model exposing (Model)
import Msg as AppMsg
import Router
import Strings
import Styles exposing (class, classList, id)
import Types


view : (Msg -> AppMsg.Msg) -> Model -> List (Html.Html AppMsg.Msg)
view lift model =
    [ Html.header [] header
    , Html.main_ [] [ Html.div [ class [ Styles.Narrow ] ] (body lift model) ]
    ]


header : List (Html.Html AppMsg.Msg)
header =
    [ Html.nav [] [ Helpers.navIcon [ class [ Styles.Big ] ] (Router.Register Nothing) "angle-double-left" ]
    , Html.h1 [] [ Html.text "Prolific Academic" ]
    ]


body : (Msg -> AppMsg.Msg) -> Model -> List (Html.Html AppMsg.Msg)
body lift model =
    let
        inner =
            case model.auth of
                Types.Anonymous ->
                    form lift model.prolific

                Types.Authenticating ->
                    [ Helpers.loading Styles.Big ]

                Types.Authenticated { user } ->
                    [ Helpers.alreadyAuthed user ]
    in
        [ Html.div [] inner ]


form : (Msg -> AppMsg.Msg) -> Form.Model String -> List (Html.Html AppMsg.Msg)
form lift { input, feedback } =
    [ Html.form [ class [ Styles.FormFlex ], Events.onSubmit (lift <| SetProlific input) ]
        [ Html.div [ class [ Styles.FormBlock ] ]
            [ Html.div []
                [ Html.div [ class [ Styles.InfoBox ] ]
                    [ Html.div []
                        [ Html.text "Not a Prolific Academic participant? "
                        , Helpers.navA [] (Router.Register Nothing) "Skip this"
                        ]
                    ]
                , Html.h2 [] [ Html.text "Welcome to Gistr!" ]
                , Html.p []
                    [ Html.text "Before we start, "
                    , Html.strong [] [ Html.text "please enter your Prolific Academic ID" ]
                    ]
                ]
            ]
        , Html.div
            [ class [ Styles.FormBlock ]
            , Helpers.errorStyle "global" feedback
            ]
            [ Html.label [ Helpers.forId Styles.InputAutofocus ]
                [ Html.text "Prolific Academic ID" ]
            , Html.div [ class [ Styles.Input, Styles.Label ] ]
                [ Html.span [ class [ Styles.Label ] ] [ Helpers.icon "barcode" ]
                , Html.input
                    [ id Styles.InputAutofocus
                    , Attributes.autofocus True
                    , Attributes.placeholder Strings.prolificIdPlaceholder
                    , Attributes.type_ "text"
                    , Attributes.value input
                    , Events.onInput (lift << SetProlificFormInput)
                    ]
                    []
                ]
            , Html.div [] [ Html.text (Feedback.getError "global" feedback) ]
            ]
        , Html.div [ class [ Styles.FormBlock ] ]
            [ Html.div []
                [ Html.p []
                    [ Html.text "You will now be taken to a registration page. "
                    , Html.strong [] [ Html.text "Simply follow the steps presented to get started with the experiment." ]
                    ]
                , Html.button
                    [ Attributes.type_ "submit", class [ Styles.Btn, Styles.BtnPrimary ] ]
                    [ Html.text "Go to registration" ]
                ]
            ]
        ]
    ]
