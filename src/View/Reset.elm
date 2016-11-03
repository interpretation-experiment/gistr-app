module View.Reset exposing (view)

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


view : Model -> Types.ResetTokens -> Html.Html Msg
view model tokens =
    Html.div [] [ header, body model tokens ]


header : Html.Html Msg
header =
    Html.div []
        [ Helpers.navButton (Router.Login Nothing) "Back"
        , Html.h1 [] [ Html.text "Password reset" ]
        ]


body : Model -> Types.ResetTokens -> Html.Html Msg
body model tokens =
    let
        inner =
            case model.reset of
                Model.Form formModel ->
                    form formModel tokens

                Model.Sent _ ->
                    sent
    in
        Html.div [] [ inner ]


form : Form.Model Types.ResetCredentials -> Types.ResetTokens -> Html.Html Msg
form { input, feedback, status } tokens =
    Html.div []
        [ Html.h2 [] [ Html.text "Set your new password" ]
        , Html.form [ Events.onSubmit (Msg.Reset input tokens) ]
            [ Html.div []
                [ Html.label [ Attributes.for "inputPassword1" ] [ Html.text "New password" ]
                , Html.input
                    [ Attributes.id "inputPassword1"
                    , Attributes.disabled (status /= Form.Entering)
                    , Attributes.autofocus True
                    , Attributes.placeholder "ubA1oh"
                    , Attributes.type' "password"
                    , Attributes.value input.password1
                    , Events.onInput (Msg.ResetFormInput << \p -> { input | password1 = p })
                    ]
                    []
                , Html.span [] [ Html.text (Feedback.getError "password1" feedback) ]
                ]
            , Html.div []
                [ Html.label [ Attributes.for "inputPassword2" ] [ Html.text "Confirm new password" ]
                , Html.input
                    [ Attributes.id "inputPassword2"
                    , Attributes.disabled (status /= Form.Entering)
                    , Attributes.placeholder "ubA1oh"
                    , Attributes.type' "password"
                    , Attributes.value input.password2
                    , Events.onInput (Msg.ResetFormInput << \p -> { input | password2 = p })
                    ]
                    []
                , Html.span [] [ Html.text (Feedback.getError "password2" feedback) ]
                ]
            , Html.div []
                [ Html.span [] [ Html.text (Feedback.getError "global" feedback) ]
                , Html.span [] [ Html.text (Feedback.getError "resetCredentials" feedback) ]
                , Html.button
                    [ Attributes.type' "submit"
                    , Attributes.disabled (status /= Form.Entering)
                    ]
                    [ Html.text "Set new password" ]
                ]
            ]
        ]


sent : Html.Html Msg
sent =
    Html.div []
        [ Html.h2 [] [ Html.text "Your new password has been saved" ]
        , Html.p []
            [ Html.text "You can try and "
            , Helpers.navA (Router.Login Nothing) "sign in"
            , Html.text " right now."
            ]
        ]
