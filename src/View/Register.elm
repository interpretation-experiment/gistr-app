module View.Register exposing (view)

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


view : Model -> Maybe String -> Html.Html Msg
view model maybeProlific =
    Html.div [] [ header, body model maybeProlific ]


header : Html.Html Msg
header =
    Html.div []
        [ Helpers.navButton Router.Home "Back"
        , Html.h1 [] [ Html.text "Sign up" ]
        ]


body : Model -> Maybe String -> Html.Html Msg
body model maybeProlific =
    let
        inner =
            case model.auth of
                Types.Anonymous ->
                    form model.register maybeProlific

                Types.Authenticating ->
                    Helpers.loading

                Types.Authenticated { user } ->
                    Helpers.alreadyAuthed user
    in
        Html.div [] [ inner ]


form : Form.Model Types.RegisterCredentials -> Maybe String -> Html.Html Msg
form { input, feedback, status } maybeProlific =
    Html.div []
        [ prolificLogin maybeProlific
        , Html.form [ Events.onSubmit (Msg.Register maybeProlific input) ]
            [ Html.div []
                [ Html.label [ Attributes.for "inputUsername" ] [ Html.text "Username" ]
                , Html.input
                    [ Attributes.id "inputUsername"
                    , Attributes.disabled (status == Form.Sending)
                    , Attributes.autofocus True
                    , Attributes.placeholder "joey"
                    , Attributes.type' "text"
                    , Attributes.value input.username
                    , Events.onInput (Msg.RegisterFormInput << \u -> { input | username = u })
                    ]
                    []
                , Html.span [] [ Html.text (Feedback.getError "username" feedback) ]
                ]
            , Html.div []
                [ Html.label [ Attributes.for "inputEmail" ] [ Html.text "Email" ]
                , Html.input
                    [ Attributes.id "inputEmail"
                    , Attributes.disabled (status == Form.Sending)
                    , Attributes.placeholder "joey@example.com (optional)"
                    , Attributes.type' "email"
                    , Attributes.value input.email
                    , Events.onInput (Msg.RegisterFormInput << \e -> { input | email = e })
                    ]
                    []
                , Html.span [] [ Html.text (Feedback.getError "email" feedback) ]
                ]
            , Html.div []
                [ Html.label [ Attributes.for "inputPassword1" ] [ Html.text "Password" ]
                , Html.input
                    [ Attributes.id "inputPassword1"
                    , Attributes.disabled (status == Form.Sending)
                    , Attributes.placeholder "ubA1oh"
                    , Attributes.type' "password"
                    , Attributes.value input.password1
                    , Events.onInput (Msg.RegisterFormInput << \p -> { input | password1 = p })
                    ]
                    []
                , Html.span [] [ Html.text (Feedback.getError "password1" feedback) ]
                ]
            , Html.div []
                [ Html.label [ Attributes.for "inputPassword2" ] [ Html.text "Confirm password" ]
                , Html.input
                    [ Attributes.id "inputPassword2"
                    , Attributes.disabled (status == Form.Sending)
                    , Attributes.placeholder "ubA1oh"
                    , Attributes.type' "password"
                    , Attributes.value input.password2
                    , Events.onInput (Msg.RegisterFormInput << \p -> { input | password2 = p })
                    ]
                    []
                , Html.span [] [ Html.text (Feedback.getError "password2" feedback) ]
                ]
            , Html.div []
                [ Html.span [] [ Html.text (Feedback.getError "global" feedback) ]
                , Html.button
                    [ Attributes.type' "submit"
                    , Attributes.disabled (status == Form.Sending)
                    ]
                    [ Html.text "Sign up" ]
                ]
            ]
        ]


prolificLogin : Maybe String -> Html.Html Msg
prolificLogin maybeProlific =
    case maybeProlific of
        Just prolificId ->
            Html.div []
                [ Html.p [] [ Html.text ("Your id is " ++ prolificId) ]
                , Html.p []
                    [ Html.text "Now, "
                    , Html.strong [] [ Html.text "sign up to start the experiment" ]
                    ]
                , Html.p []
                    [ Html.text "(Made a mistake? "
                    , Helpers.navA Router.Prolific "Go back"
                    , Html.text ")"
                    ]
                ]

        Nothing ->
            Html.div []
                [ Html.div []
                    [ Html.text "Prolific Academic participant? "
                    , Helpers.navA Router.Prolific "Please enter your ID"
                    , Html.text " first"
                    ]
                , Html.div []
                    [ Html.text "Already have an account? "
                    , Helpers.navA (Router.Login Nothing) "Sign in here"
                    ]
                ]
