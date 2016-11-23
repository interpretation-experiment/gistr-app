module Store exposing (Store)

import Types


type alias Store =
    { wordSpan : Maybe Types.WordSpan }
