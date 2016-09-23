module View.Prolific exposing (view)

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
        [ Helpers.navButton (Router.Register Nothing) "Back"
        , Html.h1 [] [ Html.text "Prolific Academic" ]
        ]


body : Model -> Html.Html Msg
body model =
    let
        inner =
            case model.auth of
                Types.Anonymous ->
                    form model.prolificModel

                Types.Authenticating ->
                    Helpers.loading

                Types.Authenticated _ user ->
                    Html.p [] [ Html.text ("Signed in as " ++ user.username) ]
    in
        Html.div [] [ inner ]


form : Model.ProlificModel -> Html.Html Msg
form { input, feedback } =
    Html.div []
        [ Html.div []
            [ Html.text "Not a Prolific Academic participant? "
            , Helpers.navA (Router.Register Nothing) "Skip this"
            ]
        , Html.h2 [] [ Html.text "Welcome to Gistr!" ]
        , Html.p []
            [ Html.text "Before we start, "
            , Html.strong [] [ Html.text "please enter your Prolific Academic ID" ]
            ]
        , Html.form [ Events.onSubmit (Msg.ProlificFormSubmit input) ]
            [ Html.div []
                [ Html.label [ Attributes.for "inputProlificId" ] [ Html.text "Prolific Academic ID" ]
                , Html.input
                    [ Attributes.id "inputProlificId"
                    , Attributes.autofocus True
                    , Attributes.placeholder "5381d3c8717b341db325eec3"
                    , Attributes.type' "text"
                    , Attributes.value input
                    , Events.onInput Msg.ProlificFormInput
                    ]
                    []
                , Html.span [] [ Html.text (Helpers.feedbackGet "global" feedback) ]
                ]
            , Html.div []
                [ Html.p []
                    [ Html.text "You will now be taken to a registration page. "
                    , Html.strong [] [ Html.text "Simply follow the steps presented to get started with the experiment." ]
                    ]
                , Html.button
                    [ Attributes.type' "submit"
                    ]
                    [ Html.text "Go to registration" ]
                ]
            ]
        ]
