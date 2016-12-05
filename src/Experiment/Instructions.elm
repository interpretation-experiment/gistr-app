module Experiment.Instructions
    exposing
        ( Node(..)
        , order
        , updateConfig
        , viewConfig
        )

import Experiment.Msg exposing (Msg(..))
import Html
import Intro
import List.Nonempty as Nonempty
import List.Nonempty exposing (Nonempty)
import Msg as AppMsg


type Node
    = Title
    | A
    | B


instructions : Nonempty ( Node, ( Intro.Position, Html.Html AppMsg.Msg ) )
instructions =
    Nonempty.Nonempty
        ( Title, ( Intro.Bottom, Html.p [] [ Html.text "This is the title!" ] ) )
        [ ( A, ( Intro.Right, Html.p [] [ Html.text "This is stuff A" ] ) )
        , ( A, ( Intro.Top, Html.p [] [ Html.text "This is stuff A again" ] ) )
        , ( B, ( Intro.Left, Html.p [] [ Html.text "And finally stuff B" ] ) )
        ]


order : Nonempty Node
order =
    Nonempty.map Tuple.first instructions


updateConfig : (Msg -> AppMsg.Msg) -> Intro.UpdateConfig Node AppMsg.Msg
updateConfig lift =
    Intro.updateConfig
        { onQuit = lift << InstructionsQuit
        , onDone = lift InstructionsDone
        }


viewConfig : (Msg -> AppMsg.Msg) -> Intro.ViewConfig Node AppMsg.Msg
viewConfig lift =
    Intro.viewConfig
        { liftMsg = lift << InstructionsMsg
        , tooltip = (\i -> Tuple.second (Nonempty.get i instructions))
        }
