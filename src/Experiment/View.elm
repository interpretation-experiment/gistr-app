module Experiment.View exposing (view)

import Experiment.Instructions as Instructions
import Experiment.Model as ExpModel
import Experiment.Msg exposing (Msg(..))
import Helpers
import Html
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
                Types.Authenticated { user } ->
                    [ header lift user.profile model.store.meta model.experiment
                    , body lift user.profile model.store.meta model.experiment
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
    -> Maybe Types.Meta
    -> ExpModel.Model
    -> Html.Html AppMsg.Msg
header lift profile meta model =
    let
        title =
            case Lifecycle.state profile of
                Lifecycle.Training _ ->
                    "Experiment — Training"

                Lifecycle.Experiment _ ->
                    "Experiment"

        instructionsState =
            case meta of
                Nothing ->
                    Intro.hide

                Just meta ->
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
    -> Maybe Types.Meta
    -> ExpModel.Model
    -> Html.Html AppMsg.Msg
body lift profile meta model =
    let
        expView =
            case model of
                ExpModel.InitialLoading ->
                    Helpers.loading

                ExpModel.Running runningState ->
                    case runningState.state of
                        ExpModel.Instructions introState ->
                            instructions lift introState

                        ExpModel.Trial _ _ ->
                            Html.div [] [ Html.text "TODO: trial" ]

                        ExpModel.Pause ->
                            Html.div [] [ Html.text "TODO: pause" ]

                        ExpModel.Finished ->
                            Html.div [] [ Html.text "TODO: finished" ]

                ExpModel.Error ->
                    Html.div [] [ Html.text "TODO: not enough sentences error" ]

        finishProfileView =
            Html.div [] [ Html.text "TODO: go finish your profile" ]

        uncompletableView =
            Html.div [] [ Html.text "TODO: state uncompletable error" ]
    in
        case meta of
            Nothing ->
                Helpers.loading

            Just meta ->
                case Lifecycle.state profile of
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


instructions : (Msg -> AppMsg.Msg) -> Intro.State Instructions.Node -> Html.Html AppMsg.Msg
instructions lift state =
    Html.p []
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
        , Helpers.evButton [] (lift StartTrial) "Start"
        , Intro.overlay state
        ]
