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
                    [ header lift user.profile model.experiment
                    , body lift user.profile model.store.meta model.experiment
                    ]

                Types.Authenticating ->
                    [ Helpers.loading ]

                Types.Anonymous ->
                    [ Helpers.notAuthed ]
    in
        Html.div [] contents


header : (Msg -> AppMsg.Msg) -> Types.Profile -> ExpModel.Model -> Html.Html AppMsg.Msg
header lift profile model =
    let
        title =
            if Lifecycle.mustTrainExperiment profile then
                "Experiment — Training"
            else
                "Experiment"
    in
        Html.div []
            [ Helpers.navButton Router.Home "Back"
            , Intro.node
                (Instructions.viewConfig lift)
                (ExpModel.instructionsState model)
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
                    Lifecycle.Experiment ->
                        if meta.experimentWork > profile.availableTreeCounts.experiment then
                            uncompletableView
                        else
                            expView

                    Lifecycle.Preliminaries preliminaries ->
                        if List.member Lifecycle.Training preliminaries then
                            if meta.trainingWork > profile.availableTreeCounts.training then
                                uncompletableView
                            else
                                expView
                        else
                            finishProfileView


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
