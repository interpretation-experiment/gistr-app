module Auth.View.Recover exposing (view)

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
import Styles exposing (class, classList, id)
import Types


view : (Msg -> AppMsg.Msg) -> Model -> List (Html.Html AppMsg.Msg)
view lift model =
    [ Html.header [] header
    , Html.main_ [] [ Html.div [ class [ Styles.Narrow ] ] (body lift model) ]
    ]


header : List (Html.Html AppMsg.Msg)
header =
    [ Html.nav [] [ Helpers.navIcon [ class [ Styles.IconBig ] ] (Router.Login Nothing) "angle-double-left" ]
    , Html.h1 [] [ Html.text "Password recovery" ]
    ]


body : (Msg -> AppMsg.Msg) -> Model -> List (Html.Html AppMsg.Msg)
body lift model =
    let
        inner =
            case model.auth of
                Types.Anonymous ->
                    case model.recover of
                        Model.Form formModel ->
                            form lift formModel

                        Model.Sent email ->
                            sent email

                Types.Authenticating ->
                    [ Helpers.loading ]

                Types.Authenticated { user } ->
                    [ Helpers.alreadyAuthed user ]
    in
        [ Html.div [] inner ]


form : (Msg -> AppMsg.Msg) -> Form.Model String -> List (Html.Html AppMsg.Msg)
form lift { input, feedback, status } =
    [ Html.form [ class [ Styles.FormFlex ], Events.onSubmit <| lift (Recover input) ]
        [ Html.div [ class [ Styles.FormBlock ] ]
            [ Html.div []
                [ Html.h2 [] [ Html.text "Reset your password" ]
                , Html.p [] [ Html.text "Type in the email address you gave for your account and we'll send you an email with instructions to reset your password." ]
                , Html.p []
                    [ Html.text "If you didn't register an email address on your account there is no way to recover your password short of "
                    , Html.a [ Attributes.href "mailto:sl@mehho.net" ] [ Html.text "contacting the developers" ]
                    , Html.text "."
                    ]
                ]
            ]
        , Html.div [ class [ Styles.FormBlock ] ]
            [ Html.label [ Attributes.for "inputEmail" ] [ Html.text "Email" ]
            , Html.div [ class [ Styles.Input, Styles.Label ] ]
                [ Html.span [ class [ Styles.Label ] ] [ Helpers.icon "envelope" ]
                , Html.input
                    [ Attributes.id "inputEmail"
                    , Attributes.disabled (status /= Form.Entering)
                    , Attributes.autofocus True
                    , Attributes.placeholder "joey@example.com"
                    , Attributes.type_ "mail"
                    , Attributes.value input
                    , Events.onInput (lift << RecoverFormInput)
                    ]
                    []
                ]
            , Html.div [] [ Html.text (Feedback.getError "global" feedback) ]
            ]
        , Html.div [ class [ Styles.FormBlock ] ]
            [ Html.div []
                [ Html.button
                    [ Attributes.type_ "submit"
                    , Attributes.disabled (status /= Form.Entering)
                    , class [ Styles.Btn, Styles.BtnPrimary ]
                    ]
                    [ Html.text "Request password reset" ]
                ]
            ]
        ]
    ]


sent : String -> List (Html.Html AppMsg.Msg)
sent email =
    [ Html.h2 [] [ Html.text "Check your inbox" ]
    , Html.p []
        [ Html.text "We just sent an email to "
        , Html.strong [] [ Html.text email ]
        , Html.text " with instructions to reset your password. Please follow its instructions."
        ]
    ]
