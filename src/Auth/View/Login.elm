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
import Types


view : (Msg -> AppMsg.Msg) -> Model -> Html.Html AppMsg.Msg
view lift model =
    Html.div [] [ header, body lift model ]


header : Html.Html AppMsg.Msg
header =
    Html.div []
        [ Helpers.navButton Router.Home "Back"
        , Html.h1 [] [ Html.text "Sign in" ]
        ]


body : (Msg -> AppMsg.Msg) -> Model -> Html.Html AppMsg.Msg
body lift model =
    let
        inner =
            case model.auth of
                Types.Anonymous ->
                    form lift model.login

                Types.Authenticating ->
                    Helpers.loading

                Types.Authenticated { user } ->
                    Helpers.alreadyAuthed user
    in
        Html.div [] [ inner ]


form : (Msg -> AppMsg.Msg) -> Form.Model Types.Credentials -> Html.Html AppMsg.Msg
form lift { input, feedback, status } =
    Html.div []
        [ Html.div []
            [ Html.text "No account yet? "
            , Helpers.navA (Router.Register Nothing) "Sign up"
            , Html.text "!"
            ]
        , Html.form [ Events.onSubmit (lift <| Login input) ]
            [ Html.div []
                [ Html.label [ Attributes.for "inputUsername" ] [ Html.text "Username" ]
                , Html.input
                    [ Attributes.id "inputUsername"
                    , Attributes.disabled (status /= Form.Entering)
                    , Attributes.autofocus True
                    , Attributes.placeholder "joey"
                    , Attributes.type' "text"
                    , Attributes.value input.username
                    , Events.onInput (lift << LoginFormInput << \u -> { input | username = u })
                    ]
                    []
                , Html.span [] [ Html.text (Feedback.getError "username" feedback) ]
                ]
            , Html.div []
                [ Html.label [ Attributes.for "inputPassword" ] [ Html.text "Password" ]
                , Html.input
                    [ Attributes.id "inputPassword"
                    , Attributes.disabled (status /= Form.Entering)
                    , Attributes.placeholder "ubA1oh"
                    , Attributes.type' "password"
                    , Attributes.value input.password
                    , Events.onInput (lift << LoginFormInput << \p -> { input | password = p })
                    ]
                    []
                , Html.span [] [ Html.text (Feedback.getError "password" feedback) ]
                ]
            , Html.div []
                [ Html.span [] [ Html.text (Feedback.getError "global" feedback) ]
                , Html.button
                    [ Attributes.type' "submit"
                    , Attributes.disabled (status /= Form.Entering)
                    ]
                    [ Html.text "Sign in" ]
                , Helpers.navA Router.Recover "I forgot my password"
                ]
            ]
        ]
