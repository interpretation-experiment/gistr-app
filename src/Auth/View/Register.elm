module Auth.View.Register exposing (view)

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


view : (Msg -> AppMsg.Msg) -> Model -> Maybe String -> List (Html.Html AppMsg.Msg)
view lift model maybeProlific =
    [ Html.header [] header
    , Html.main_ [] [ Html.div [ class [ Styles.Narrow ] ] (body lift model maybeProlific) ]
    ]


header : List (Html.Html AppMsg.Msg)
header =
    [ Html.nav [] [ Helpers.navIcon [ class [ Styles.IconBig ] ] Router.Home "home" ]
    , Html.h1 [] [ Html.text "Sign up" ]
    ]


body : (Msg -> AppMsg.Msg) -> Model -> Maybe String -> List (Html.Html AppMsg.Msg)
body lift model maybeProlific =
    let
        inner =
            case model.auth of
                Types.Anonymous ->
                    form lift model.register maybeProlific

                Types.Authenticating ->
                    [ Helpers.loading ]

                Types.Authenticated { user } ->
                    [ Helpers.alreadyAuthed user ]
    in
        [ Html.div [] inner ]


form :
    (Msg -> AppMsg.Msg)
    -> Form.Model Types.RegisterCredentials
    -> Maybe String
    -> List (Html.Html AppMsg.Msg)
form lift { input, feedback, status } maybeProlific =
    [ prolificLogin maybeProlific
    , Html.form [ Events.onSubmit <| lift (Register maybeProlific input) ]
        [ Html.div []
            [ Html.label [ Attributes.for "inputUsername" ] [ Html.text "Username" ]
            , Html.div [ class [ Styles.Input, Styles.Label ] ]
                [ Html.span [ class [ Styles.Label ] ] [ Helpers.icon "user" ]
                , Html.input
                    [ Attributes.id "inputUsername"
                    , Attributes.disabled (status /= Form.Entering)
                    , Attributes.autofocus True
                    , Attributes.placeholder "joey"
                    , Attributes.type_ "text"
                    , Attributes.value input.username
                    , Events.onInput <|
                        lift
                            << (RegisterFormInput << \u -> { input | username = u })
                    ]
                    []
                ]
            , Html.span [] [ Html.text (Feedback.getError "username" feedback) ]
            ]
        , Html.div []
            [ Html.label [ Attributes.for "inputEmail" ] [ Html.text "Email" ]
            , Html.div [ class [ Styles.Input, Styles.Label ] ]
                [ Html.span [ class [ Styles.Label ] ] [ Helpers.icon "envelope" ]
                , Html.input
                    [ Attributes.id "inputEmail"
                    , Attributes.disabled (status /= Form.Entering)
                    , Attributes.placeholder "joey@example.com (optional)"
                    , Attributes.type_ "email"
                    , Attributes.value input.email
                    , Events.onInput <|
                        lift
                            << (RegisterFormInput << \e -> { input | email = e })
                    ]
                    []
                ]
            , Html.span [] [ Html.text (Feedback.getError "email" feedback) ]
            ]
        , Html.div []
            [ Html.label [ Attributes.for "inputPassword1" ] [ Html.text "Password" ]
            , Html.div [ class [ Styles.Input, Styles.Label ] ]
                [ Html.span [ class [ Styles.Label ] ] [ Helpers.icon "lock" ]
                , Html.input
                    [ Attributes.id "inputPassword1"
                    , Attributes.disabled (status /= Form.Entering)
                    , Attributes.placeholder "ubA1oh"
                    , Attributes.type_ "password"
                    , Attributes.value input.password1
                    , Events.onInput <|
                        lift
                            << (RegisterFormInput << \p -> { input | password1 = p })
                    ]
                    []
                ]
            , Html.span [] [ Html.text (Feedback.getError "password1" feedback) ]
            ]
        , Html.div []
            [ Html.label [ Attributes.for "inputPassword2" ]
                [ Html.text "Confirm password" ]
            , Html.div [ class [ Styles.Input, Styles.Label ] ]
                [ Html.span [ class [ Styles.Label ] ] [ Helpers.icon "lock" ]
                , Html.input
                    [ Attributes.id "inputPassword2"
                    , Attributes.disabled (status /= Form.Entering)
                    , Attributes.placeholder "ubA1oh"
                    , Attributes.type_ "password"
                    , Attributes.value input.password2
                    , Events.onInput <|
                        lift
                            << (RegisterFormInput << \p -> { input | password2 = p })
                    ]
                    []
                ]
            , Html.span [] [ Html.text (Feedback.getError "password2" feedback) ]
            ]
        , Html.div []
            [ Html.span [] [ Html.text (Feedback.getError "global" feedback) ]
            , Html.button
                [ Attributes.type_ "submit"
                , Attributes.disabled (status /= Form.Entering)
                , class [ Styles.Btn, Styles.BtnPrimary ]
                ]
                [ Html.text "Sign up" ]
            ]
        ]
    ]


prolificLogin : Maybe String -> Html.Html AppMsg.Msg
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
