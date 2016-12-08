port module Dom.Extra exposing (click, ctrlEnter)


port click : String -> Cmd msg


port ctrlEnter : (() -> msg) -> Sub msg
