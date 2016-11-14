module Experiment.View exposing (view)

import Clock
import Experiment.Instructions as Instructions
import Experiment.Model as ExpModel
import Experiment.Msg exposing (Msg(..))
import Feedback
import Form
import Helpers
import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Intro
import Lifecycle
import Model exposing (Model)
import Msg as AppMsg
import Router
import Types


view : (Msg -> AppMsg.Msg) -> Model -> Html.Html AppMsg.Msg
view lift model =
    let
        contents =
            case model.auth of
                Types.Authenticated { user, meta } ->
                    [ header lift user.profile meta model.experiment
                    , body lift user.profile meta model.experiment
                    ]

                Types.Authenticating ->
                    [ Helpers.loading ]

                Types.Anonymous ->
                    [ Helpers.notAuthed ]
    in
        Html.div [] contents


header :
    (Msg -> AppMsg.Msg)
    -> Types.Profile
    -> Types.Meta
    -> ExpModel.Model
    -> Html.Html AppMsg.Msg
header lift profile meta model =
    let
        title =
            case Lifecycle.state meta profile of
                Lifecycle.Training _ ->
                    "Experiment — Training"

                Lifecycle.Experiment _ ->
                    "Experiment"

                Lifecycle.Done ->
                    "Experiment — Done"

        instructionsState =
            if Lifecycle.stateIsCompletable meta profile then
                ExpModel.instructionsState model
            else
                Intro.hide
    in
        Html.div []
            [ Helpers.navButton Router.Home "Back"
            , Intro.node
                (Instructions.viewConfig lift)
                instructionsState
                Instructions.Title
                Html.h1
                []
                [ Html.text title ]
            ]


body :
    (Msg -> AppMsg.Msg)
    -> Types.Profile
    -> Types.Meta
    -> ExpModel.Model
    -> Html.Html AppMsg.Msg
body lift profile meta model =
    let
        expView =
            case model of
                ExpModel.Init ->
                    -- TODO: if in done with prolific academic code, show code
                    Helpers.loading

                ExpModel.Running runningState ->
                    case runningState.state of
                        ExpModel.JustFinished ->
                            Html.div [] [ Html.text "TODO: just finished previous run" ]

                        ExpModel.Instructions introState ->
                            instructions lift introState

                        ExpModel.Trial sentence state ->
                            trial lift sentence state

                        ExpModel.Pause ->
                            Html.div [] [ Html.text "TODO: pause" ]

                ExpModel.Error ->
                    Html.div [] [ Html.text "TODO: not enough sentences error" ]

        finishProfileView =
            Html.div [] [ Html.text "TODO: go finish your profile" ]

        uncompletableView =
            Html.div [] [ Html.text "TODO: state uncompletable error" ]
    in
        case Lifecycle.state meta profile of
            Lifecycle.Experiment tests ->
                if List.length tests == 0 then
                    if Lifecycle.stateIsCompletable meta profile then
                        expView
                    else
                        uncompletableView
                else
                    finishProfileView

            Lifecycle.Training _ ->
                if Lifecycle.stateIsCompletable meta profile then
                    expView
                else
                    uncompletableView

            Lifecycle.Done ->
                expView


instructions : (Msg -> AppMsg.Msg) -> Intro.State Instructions.Node -> Html.Html AppMsg.Msg
instructions lift state =
    Html.div []
        [ Intro.node
            (Instructions.viewConfig lift)
            state
            Instructions.A
            Html.p
            []
            [ Html.text "First stuff" ]
        , Intro.node
            (Instructions.viewConfig lift)
            state
            Instructions.B
            Html.p
            []
            [ Html.text "Second stuff" ]
        , Helpers.evButton [] (lift InstructionsStart) "Replay instructions"
        , Helpers.evButton [] (lift LoadTrial) "Start"
        , Intro.overlay state
        ]


trial : (Msg -> AppMsg.Msg) -> Types.Sentence -> ExpModel.TrialState -> Html.Html AppMsg.Msg
trial lift sentence state =
    case state of
        ExpModel.Reading clock ->
            -- TODO
            Html.div []
                [ Html.text "Read"
                , Html.p [] [ Html.text sentence.text ]
                , Clock.view clock
                ]

        ExpModel.Tasking clock ->
            -- TODO
            Html.div []
                [ Html.text "Tasking"
                , Clock.view clock
                ]

        ExpModel.Writing clock form ->
            write lift sentence clock form

        ExpModel.Timeout ->
            Html.div []
                [ Html.text "TODO: timeout"
                , Helpers.evButton [] (lift LoadTrial) "Next"
                ]


write :
    (Msg -> AppMsg.Msg)
    -> Types.Sentence
    -> Clock.Model
    -> Form.Model String
    -> Html.Html AppMsg.Msg
write lift sentence clock { input, feedback, status } =
    Html.div []
        [ Html.text "Write"
        , Html.form [ Events.onSubmit (lift <| WriteSubmit input) ]
            [ Html.div []
                [ Html.label [ Attributes.for "inputText" ] [ Html.text "Write:" ]
                , Html.textarea
                    [ Attributes.id "inputText"
                    , Attributes.autofocus True
                    , Attributes.value input
                    , Events.onInput (lift << WriteInput)
                    ]
                    []
                , Html.span [] [ Html.text (Feedback.getError "global" feedback) ]
                ]
            , Html.button
                [ Attributes.type' "submit" ]
                [ Html.text "Send" ]
            ]
        , Clock.view clock
        ]
