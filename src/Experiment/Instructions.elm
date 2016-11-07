module Experiment.Instructions
    exposing
        ( Instruction(..)
        , order
        , updateConfig
        , viewConfig
        )

import Experiment.Msg exposing (Msg(..))
import Html
import Intro
import List.Extra exposing (getAt)
import List.Nonempty as Nonempty
import List.Nonempty exposing (Nonempty)
import Msg as AppMsg


type Instruction
    = InstructionTitle
    | InstructionA
    | InstructionB


instructions : Nonempty ( Instruction, Html.Html AppMsg.Msg )
instructions =
    Nonempty.Nonempty
        ( InstructionTitle, Html.p [] [ Html.text "This is the title!" ] )
        [ ( InstructionA, Html.p [] [ Html.text "This is stuff A" ] )
        , ( InstructionA, Html.p [] [ Html.text "This is stuff A again" ] )
        , ( InstructionB, Html.p [] [ Html.text "And finally stuff B" ] )
        ]


order : Nonempty Instruction
order =
    Nonempty.map fst instructions


updateConfig : (Msg -> AppMsg.Msg) -> Intro.UpdateConfig Instruction AppMsg.Msg
updateConfig lift =
    Intro.updateConfig
        { onQuit = lift << InstructionsQuit
        , onDone = lift InstructionsDone
        }


viewConfig : (Msg -> AppMsg.Msg) -> Intro.ViewConfig Instruction AppMsg.Msg
viewConfig lift =
    Intro.viewConfig
        { liftMsg = lift << InstructionsMsg
        , tooltip = (\i -> snd (Nonempty.get i instructions))
        }
