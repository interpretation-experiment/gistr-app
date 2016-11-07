module Experiment.View exposing (view)

import Experiment.Instructions as Instructions
import Experiment.Model as ExpModel
import Experiment.Msg exposing (Msg(..))
import Helpers
import Html
import Intro
import Model exposing (Model)
import Msg as AppMsg
import Router


view : (Msg -> AppMsg.Msg) -> Model -> Html.Html AppMsg.Msg
view lift model =
    Html.div [] [ header lift model.experiment, body lift model ]


header : (Msg -> AppMsg.Msg) -> ExpModel.State a -> Html.Html AppMsg.Msg
header lift experiment =
    let
        state =
            case experiment of
                ExpModel.Instructions _ ->
                    "Instructions"

                ExpModel.Training _ ->
                    "Training"

                ExpModel.Exping _ ->
                    "Experiment"
    in
        Html.div []
            [ Helpers.navButton Router.Home "Back"
            , Intro.node
                (Instructions.viewConfig lift)
                (ExpModel.instructionsState experiment)
                Instructions.InstructionTitle
                Html.h1
                []
                [ Html.text ("Experiment — " ++ state) ]
            ]


body : (Msg -> AppMsg.Msg) -> Model -> Html.Html AppMsg.Msg
body lift model =
    case model.experiment of
        ExpModel.Instructions introState ->
            intro lift introState

        _ ->
            Html.div [] []


intro : (Msg -> AppMsg.Msg) -> Intro.State Instructions.Instruction -> Html.Html AppMsg.Msg
intro lift state =
    Html.p []
        [ Intro.node
            (Instructions.viewConfig lift)
            state
            Instructions.InstructionA
            Html.p
            []
            [ Html.text "First stuff" ]
        , Intro.node
            (Instructions.viewConfig lift)
            state
            Instructions.InstructionB
            Html.p
            []
            [ Html.text "Second stuff" ]
        , Helpers.evButton [] (lift InstructionsRestart) "Replay instructions"
        , Helpers.evButton [] (lift Start) "Start"
        , Intro.overlay state
        ]
