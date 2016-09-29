module View.Recover exposing (view)

import Feedback
import Form
import Helpers
import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Model exposing (Model)
import Msg exposing (Msg)
import Router
import Types


view : Model -> Html.Html Msg
view model =
    Html.div [] [ header, body model ]


header : Html.Html Msg
header =
    Html.div []
        [ Helpers.navButton (Router.Login Nothing) "Back"
        , Html.h1 [] [ Html.text "Password recovery" ]
        ]


body : Model -> Html.Html Msg
body model =
    let
        inner =
            case model.auth of
                Types.Anonymous ->
                    case model.recover of
                        Model.Form formModel ->
                            form formModel

                        Model.Sent email ->
                            sent email

                Types.Authenticating ->
                    Helpers.loading

                Types.Authenticated { user } ->
                    Helpers.alreadyAuthed user
    in
        Html.div [] [ inner ]


form : Form.Model String -> Html.Html Msg
form { input, feedback, status } =
    Html.div []
        [ Html.h2 [] [ Html.text "Reset your password" ]
        , Html.p [] [ Html.text "Type in the email address you gave for your account and we'll send you an email with instructions to reset your password." ]
        , Html.p []
            [ Html.text "If you didn't register an email address on your account there is no way to recover your password short of "
            , Html.a [ Attributes.href "mailto:sl@mehho.net" ] [ Html.text "contacting the developers" ]
            , Html.text "."
            ]
        , Html.form [ Events.onSubmit (Msg.Recover input) ]
            [ Html.div []
                [ Html.label [ Attributes.for "inputEmail" ] [ Html.text "Email" ]
                , Html.input
                    [ Attributes.id "inputEmail"
                    , Attributes.disabled (status == Form.Sending)
                    , Attributes.autofocus True
                    , Attributes.placeholder "joey@example.com"
                    , Attributes.type' "mail"
                    , Attributes.value input
                    , Events.onInput Msg.RecoverFormInput
                    ]
                    []
                ]
            , Html.div []
                [ Html.span [] [ Html.text (Feedback.getError "global" feedback) ]
                , Html.button
                    [ Attributes.type' "submit"
                    , Attributes.disabled (status == Form.Sending)
                    ]
                    [ Html.text "Request password reset" ]
                ]
            ]
        ]


sent : String -> Html.Html Msg
sent email =
    Html.div []
        [ Html.h2 [] [ Html.text "Check your inbox" ]
        , Html.p []
            [ Html.text "We just sent an email to "
            , Html.strong [] [ Html.text email ]
            , Html.text " with instructions to reset your password. Please follow its instructions."
            ]
        ]
