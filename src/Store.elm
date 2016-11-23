module Store
    exposing
        ( Store
        , emptyStore
        )

import Types


type alias Store =
    { wordSpan : Maybe Types.WordSpan }


emptyStore : Store
emptyStore =
    { wordSpan = Nothing }
