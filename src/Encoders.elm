module Encoders exposing (credentials)

import Json.Encode as JE
import Types


credentials : Types.Credentials -> JE.Value
credentials credentials' =
    JE.object
        [ ( "username", JE.string credentials'.username )
        , ( "password", JE.string credentials'.password )
        ]
