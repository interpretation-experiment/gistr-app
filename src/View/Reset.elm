module View.Reset exposing (view)

import Helpers
import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Model exposing (Model)
import Msg exposing (Msg)
import Router


view : Model -> String -> String -> Html.Html Msg
view model uid token =
    Html.div [] [ header, body model uid token ]


header : Html.Html Msg
header =
    Html.div []
        [ Helpers.navButton (Router.Login Nothing) "Back"
        , Html.h1 [] [ Html.text "Password reset" ]
        ]


body : Model -> String -> String -> Html.Html Msg
body model uid token =
    let
        inner =
            case model.resetModel.status of
                Model.Form formStatus ->
                    form model.resetModel uid token formStatus

                Model.Sent ->
                    sent
    in
        Html.div [] [ inner ]


form : Model.ResetModel -> String -> String -> Model.FormStatus -> Html.Html Msg
form { input, feedback } uid token formStatus =
    Html.div []
        [ Html.h2 [] [ Html.text "Set your new password" ]
        , Html.form [ Events.onSubmit (Msg.Reset input uid token) ]
            [ Html.div []
                [ Html.label [ Attributes.for "inputPassword1" ] [ Html.text "New password" ]
                , Html.input
                    [ Attributes.id "inputPassword1"
                    , Attributes.disabled (formStatus == Model.Sending)
                    , Attributes.autofocus True
                    , Attributes.placeholder "ubA1oh"
                    , Attributes.type' "password"
                    , Attributes.value input.password1
                    , Events.onInput (Msg.ResetFormInput << \p -> { input | password1 = p })
                    ]
                    []
                , Html.span [] [ Html.text (Helpers.feedbackGet "password1" feedback) ]
                ]
            , Html.div []
                [ Html.label [ Attributes.for "inputPassword2" ] [ Html.text "Confirm new password" ]
                , Html.input
                    [ Attributes.id "inputPassword2"
                    , Attributes.disabled (formStatus == Model.Sending)
                    , Attributes.placeholder "ubA1oh"
                    , Attributes.type' "password"
                    , Attributes.value input.password2
                    , Events.onInput (Msg.ResetFormInput << \p -> { input | password2 = p })
                    ]
                    []
                , Html.span [] [ Html.text (Helpers.feedbackGet "password2" feedback) ]
                ]
            , Html.div []
                [ Html.span [] [ Html.text (Helpers.feedbackGet "global" feedback) ]
                , Html.span [] [ Html.text (Helpers.feedbackGet "resetCredentials" feedback) ]
                , Html.button
                    [ Attributes.type' "submit"
                    , Attributes.disabled (formStatus == Model.Sending)
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
