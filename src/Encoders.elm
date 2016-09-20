module Encoders
    exposing
        ( credentials
        , email
        )

import Json.Encode as JE
import Types


credentials : Types.Credentials -> JE.Value
credentials credentials' =
    JE.object
        [ ( "username", JE.string credentials'.username )
        , ( "password", JE.string credentials'.password )
        ]


email : String -> JE.Value
email email' =
    JE.object [ ( "email", JE.string email' ) ]
