module Auth.View.Login exposing (view)

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
    , Html.main_ [] [ Html.div [ class [ Styles.SuperNarrow ] ] (body lift model) ]
    ]


header : List (Html.Html AppMsg.Msg)
header =
    [ Html.nav [] [ Helpers.navIcon [ class [ Styles.Big ] ] Router.Home "home" ]
    , Html.h1 [] [ Html.text "Sign in" ]
    ]


body : (Msg -> AppMsg.Msg) -> Model -> List (Html.Html AppMsg.Msg)
body lift model =
    let
        inner =
            case model.auth of
                Types.Anonymous ->
                    form lift model.login

                Types.Authenticating ->
                    [ Helpers.loading Styles.Big ]

                Types.Authenticated { user } ->
                    [ Helpers.alreadyAuthed user ]
    in
        [ Html.div [] inner ]


form : (Msg -> AppMsg.Msg) -> Form.Model Types.Credentials -> List (Html.Html AppMsg.Msg)
form lift { input, feedback, status } =
    [ Html.form [ class [ Styles.FormFlex ], Events.onSubmit (lift <| Login input) ]
        [ Html.div [ class [ Styles.FormBlock ] ]
            [ Html.div [ class [ Styles.InfoBox ] ]
                [ Html.div []
                    [ Html.text "No account yet? "
                    , Helpers.navA [] (Router.Register Nothing) "Sign up"
                    , Html.text "!"
                    ]
                ]
            ]
        , Html.div
            [ class [ Styles.FormBlock ]
            , Helpers.feedbackStyles "username" feedback
            ]
            [ Html.label [ Helpers.forId Styles.InputAutofocus ]
                [ Html.text "Username" ]
            , Html.div [ class [ Styles.Input, Styles.Label ] ]
                [ Html.span [ class [ Styles.Label ] ] [ Helpers.icon "user" ]
                , Html.input
                    [ id Styles.InputAutofocus
                    , Attributes.disabled (status /= Form.Entering)
                    , Attributes.autofocus True
                    , Attributes.placeholder Strings.usernamePlaceholder
                    , Attributes.type_ "text"
                    , Attributes.value input.username
                    , Events.onInput
                        (lift << LoginFormInput << \u -> { input | username = u })
                    ]
                    []
                ]
            , Html.div [] [ Html.text (Feedback.getError "username" feedback) ]
            ]
        , Html.div
            [ class [ Styles.FormBlock ]
            , Helpers.feedbackStyles "password" feedback
            ]
            [ Html.label [ Attributes.for "inputPassword" ] [ Html.text "Password" ]
            , Html.div [ class [ Styles.Input, Styles.Label ] ]
                [ Html.span [ class [ Styles.Label ] ] [ Helpers.icon "lock" ]
                , Html.input
                    [ Attributes.id "inputPassword"
                    , Attributes.disabled (status /= Form.Entering)
                    , Attributes.placeholder Strings.passwordPlaceholder1
                    , Attributes.type_ "password"
                    , Attributes.value input.password
                    , Events.onInput
                        (lift << LoginFormInput << \p -> { input | password = p })
                    ]
                    []
                ]
            , Html.div [] [ Html.text (Feedback.getError "password" feedback) ]
            ]
        , Html.div [ class [ Styles.FormBlock ] ]
            [ Html.div [ class [ Styles.Error ] ] [ Html.text (Feedback.getError "global" feedback) ]
            , Html.div []
                [ Html.button
                    [ Attributes.type_ "submit"
                    , Attributes.disabled (status /= Form.Entering)
                    , class [ Styles.Btn, Styles.BtnPrimary ]
                    ]
                    [ Html.text "Sign in" ]
                , Helpers.navButton
                    [ class [ Styles.BtnLink ] ]
                    Router.Recover
                    "I forgot my password"
                ]
            ]
        ]
    ]
