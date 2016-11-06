module Experiment.Reformulation
    exposing
        ( Instruction(..)
        , SeriesState(..)
        , TrialState(..)
        , instructionsOrder
        , instructionsUpdateConfig
        , instructionsViewConfig
        )

import Html
import Instructions
import List.Extra exposing (getAt)
import List.Nonempty as Nonempty
import List.Nonempty exposing (Nonempty)
import Maybe.Extra exposing (unwrap)
import Msg exposing (Msg)


-- INSTRUCTIONS


type Instruction
    = InstructionTitle
    | InstructionA
    | InstructionB


instructions : Nonempty ( Instruction, Html.Html Msg )
instructions =
    Nonempty.Nonempty
        ( InstructionTitle, Html.p [] [ Html.text "This is the title!" ] )
        [ ( InstructionA, Html.p [] [ Html.text "This is stuff A" ] )
        , ( InstructionA, Html.p [] [ Html.text "This is stuff A again" ] )
        , ( InstructionB, Html.p [] [ Html.text "And finally stuff B" ] )
        ]


instructionsOrder : Nonempty Instruction
instructionsOrder =
    Nonempty.map fst instructions


instructionsUpdateConfig : Instructions.UpdateConfig Instruction Msg
instructionsUpdateConfig =
    Instructions.updateConfig
        { onQuit = Msg.ReformulationInstructionsQuit
        , onDone = Msg.ReformulationInstructionsDone
        }


instructionsViewConfig : Instructions.ViewConfig Instruction Msg
instructionsViewConfig =
    Instructions.viewConfig
        { liftMsg = Msg.ReformulationInstructions
        , tooltip = (\i -> snd (Nonempty.get i instructions))
        }



-- STATE


type SeriesState a
    = Trial a TrialState
    | Pause
    | Finished


type TrialState
    = Reading
    | Tasking
    | Writing
