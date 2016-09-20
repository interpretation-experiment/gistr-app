module View.Login exposing (view)

import Dict
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
        [ Helpers.navButton Router.Home "Back"
        , Html.h1 [] [ Html.text "Sign in" ]
        ]


body : Model -> Html.Html Msg
body model =
    let
        inner =
            case model.auth of
                Types.Anonymous ->
                    form model.loginModel True

                Types.Authenticating ->
                    form model.loginModel False

                Types.Authenticated _ user ->
                    Html.p [] [ Html.text ("Signed in as " ++ user.username) ]
    in
        Html.div [] [ inner ]


form : Model.FormModel Types.Credentials -> Bool -> Html.Html Msg
form { input, feedback } enabled =
    Html.div []
        [ Html.div []
            [ Html.text "No account yet? "
            , Helpers.navA Router.Home "Sign up"
            , Html.text "!"
              -- DO: set destination to Register
            ]
        , Html.form [ Events.onSubmit (Msg.Login input) ]
            [ Html.div []
                [ Html.label [ Attributes.for "inputUsername" ] [ Html.text "Username" ]
                , Html.input
                    [ Attributes.id "inputUsername"
                    , Attributes.disabled (not enabled)
                    , Attributes.autofocus True
                    , Attributes.placeholder "joey"
                    , Attributes.type' "text"
                    , Attributes.value input.username
                    , Events.onInput Msg.LoginFormUsername
                    ]
                    []
                , Html.span [] [ Html.text (Helpers.feedbackGet "username" feedback) ]
                ]
            , Html.div []
                [ Html.label [ Attributes.for "inputPassword" ] [ Html.text "Password" ]
                , Html.input
                    [ Attributes.id "inputPassword"
                    , Attributes.disabled (not enabled)
                    , Attributes.placeholder "ubA1oh"
                    , Attributes.type' "password"
                    , Attributes.value input.password
                    , Events.onInput Msg.LoginFormPassword
                    ]
                    []
                , Html.span [] [ Html.text (Helpers.feedbackGet "password" feedback) ]
                ]
            , Html.div []
                [ Html.span [] [ Html.text (Helpers.feedbackGet "global" feedback) ]
                , Html.button
                    [ Attributes.type' "submit"
                    , Attributes.disabled (not enabled)
                    ]
                    [ Html.text "Sign in" ]
                , Helpers.navA Router.Recover "I forgot my password"
                ]
            ]
        ]
