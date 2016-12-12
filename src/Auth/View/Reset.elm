module Auth.View.Reset exposing (view)

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


view : (Msg -> AppMsg.Msg) -> Model -> Types.ResetTokens -> List (Html.Html AppMsg.Msg)
view lift model tokens =
    [ Html.header [] header
    , Html.main_ [] [ Html.div [ class [ Styles.Narrow ] ] (body lift model tokens) ]
    ]


header : List (Html.Html AppMsg.Msg)
header =
    [ Html.nav [] [ Helpers.navIcon [ class [ Styles.Big ] ] (Router.Login Nothing) "angle-double-left" ]
    , Html.h1 [] [ Html.text "Password reset" ]
    ]


body : (Msg -> AppMsg.Msg) -> Model -> Types.ResetTokens -> List (Html.Html AppMsg.Msg)
body lift model tokens =
    let
        inner =
            case model.reset of
                Model.Form formModel ->
                    form lift formModel tokens

                Model.Sent _ ->
                    sent
    in
        [ Html.div [] inner ]


form :
    (Msg -> AppMsg.Msg)
    -> Form.Model Types.ResetCredentials
    -> Types.ResetTokens
    -> List (Html.Html AppMsg.Msg)
form lift { input, feedback, status } tokens =
    [ Html.form [ class [ Styles.FormFlex ], Events.onSubmit <| lift (Reset input tokens) ]
        [ Html.div [ class [ Styles.FormBlock ] ]
            [ Html.div [] [ Html.h2 [] [ Html.text "Set your new password" ] ] ]
        , Html.div [ class [ Styles.FormBlock ], Helpers.errorStyle "password1" feedback ]
            [ Html.label [ Helpers.forId Styles.InputAutofocus ]
                [ Html.text "New password" ]
            , Html.div [ class [ Styles.Input, Styles.Label ] ]
                [ Html.span [ class [ Styles.Label ] ] [ Helpers.icon "lock" ]
                , Html.input
                    [ id Styles.InputAutofocus
                    , Attributes.disabled (status /= Form.Entering)
                    , Attributes.autofocus True
                    , Attributes.placeholder Strings.passwordPlaceholder1
                    , Attributes.type_ "password"
                    , Attributes.value input.password1
                    , Events.onInput <|
                        lift
                            << (ResetFormInput << \p -> { input | password1 = p })
                    ]
                    []
                ]
            , Html.div [] [ Html.text (Feedback.getError "password1" feedback) ]
            ]
        , Html.div [ class [ Styles.FormBlock ], Helpers.errorStyle "password2" feedback ]
            [ Html.label [ Attributes.for "inputPassword2" ]
                [ Html.text "Confirm new password" ]
            , Html.div [ class [ Styles.Input, Styles.Label ] ]
                [ Html.span [ class [ Styles.Label ] ] [ Helpers.icon "lock" ]
                , Html.input
                    [ Attributes.id "inputPassword2"
                    , Attributes.disabled (status /= Form.Entering)
                    , Attributes.placeholder Strings.passwordPlaceholder2
                    , Attributes.type_ "password"
                    , Attributes.value input.password2
                    , Events.onInput <|
                        lift
                            << (ResetFormInput << \p -> { input | password2 = p })
                    ]
                    []
                ]
            , Html.div [] [ Html.text (Feedback.getError "password2" feedback) ]
            ]
        , Html.div [ class [ Styles.FormBlock ] ]
            [ Html.div [ class [ Styles.Error ] ]
                [ Html.span [] [ Html.text (Feedback.getError "global" feedback) ]
                , Html.span [] [ Html.text (Feedback.getError "resetCredentials" feedback) ]
                ]
            , Html.div []
                [ Html.button
                    [ Attributes.type_ "submit"
                    , Attributes.disabled (status /= Form.Entering)
                    , class [ Styles.Btn, Styles.BtnPrimary ]
                    ]
                    [ Html.text "Set new password" ]
                ]
            ]
        ]
    ]


sent : List (Html.Html AppMsg.Msg)
sent =
    [ Html.h2 [] [ Html.text "Your new password has been saved" ]
    , Html.p []
        [ Html.text "You can try and "
        , Helpers.navA [] (Router.Login Nothing) "sign in"
        , Html.text " right now."
        ]
    ]
