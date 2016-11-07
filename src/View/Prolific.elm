module View.Prolific exposing (view)

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
        [ Helpers.navButton (Router.Register Nothing) "Back"
        , Html.h1 [] [ Html.text "Prolific Academic" ]
        ]


body : (Msg -> AppMsg.Msg) -> Model -> Html.Html AppMsg.Msg
body lift model =
    let
        inner =
            case model.auth of
                Types.Anonymous ->
                    form lift model.prolific

                Types.Authenticating ->
                    Helpers.loading

                Types.Authenticated { user } ->
                    Helpers.alreadyAuthed user
    in
        Html.div [] [ inner ]


form : (Msg -> AppMsg.Msg) -> Form.Model String -> Html.Html AppMsg.Msg
form lift { input, feedback } =
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
        , Html.form [ Events.onSubmit (lift <| SetProlific input) ]
            [ Html.div []
                [ Html.label [ Attributes.for "inputProlificId" ] [ Html.text "Prolific Academic ID" ]
                , Html.input
                    [ Attributes.id "inputProlificId"
                    , Attributes.autofocus True
                    , Attributes.placeholder "5381d3c8717b341db325eec3"
                    , Attributes.type' "text"
                    , Attributes.value input
                    , Events.onInput (lift << SetProlificFormInput)
                    ]
                    []
                , Html.span [] [ Html.text (Feedback.getError "global" feedback) ]
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
