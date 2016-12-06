module Home.Instructions
    exposing
        ( Node(..)
        , order
        , updateConfig
        , viewConfig
        )

import Home.Msg exposing (Msg(..))
import Html
import Intro
import List.Nonempty as Nonempty
import List.Nonempty exposing (Nonempty)
import Msg as AppMsg


type Node
    = Greeting
    | Profile
    | Body


instructions : Nonempty ( Node, ( Intro.Position, Html.Html AppMsg.Msg ) )
instructions =
    Nonempty.Nonempty
        ( Greeting
        , ( Intro.Bottom
          , Html.p [] [ Html.text "Hi! Welcome to the Gistr Experiment :-)" ]
          )
        )
        [ ( Profile
          , ( Intro.Left
            , Html.div []
                [ Html.p []
                    [ Html.text
                        ("There are a few tests and a questionnaire "
                            ++ "to fill in your profile page."
                        )
                    ]
                , Html.p [] [ Html.text "Feel free to do them when you want to!" ]
                ]
            )
          )
        , ( Body
          , ( Intro.Bottom
            , Html.p []
                [ Html.text
                    ("Get going on the experiment now! "
                        ++ "You'll get to know all about it afterwards."
                    )
                ]
            )
          )
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
