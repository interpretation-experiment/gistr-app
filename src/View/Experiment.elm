module View.Experiment exposing (view)

import Experiment
import Experiment.Reformulation as Reformulation
import Helpers
import Html
import Instructions
import Model exposing (Model)
import Msg exposing (Msg)
import Router


view : Model -> Html.Html Msg
view model =
    Html.div [] [ header model.experiment, body model ]


header : Experiment.State Reformulation.Instruction a -> Html.Html Msg
header experiment =
    let
        state =
            case experiment of
                Experiment.Instructions _ ->
                    "Instructions"

                Experiment.Training _ ->
                    "Training"

                Experiment.Exping _ ->
                    "Experiment"
    in
        Html.div []
            [ Helpers.navButton Router.Home "Back"
            , Instructions.node
                Reformulation.instructionsViewConfig
                (Experiment.instructionsState experiment)
                Reformulation.InstructionTitle
                Html.h1
                []
                [ Html.text ("Experiment — " ++ state) ]
            ]


body : Model -> Html.Html Msg
body model =
    case model.experiment of
        Experiment.Instructions introState ->
            intro introState

        _ ->
            Html.div [] []


intro : Instructions.State Reformulation.Instruction -> Html.Html Msg
intro state =
    Html.p []
        [ Instructions.node
            Reformulation.instructionsViewConfig
            state
            Reformulation.InstructionA
            Html.p
            []
            [ Html.text "First stuff" ]
        , Instructions.node
            Reformulation.instructionsViewConfig
            state
            Reformulation.InstructionB
            Html.p
            []
            [ Html.text "Second stuff" ]
        , Helpers.evButton [] Msg.ReformulationInstructionsRestart "Replay instructions"
        , Helpers.evButton [] Msg.ReformulationExpStart "Start"
        , Instructions.overlay state
        ]
