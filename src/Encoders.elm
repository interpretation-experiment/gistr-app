module Encoders
    exposing
        ( credentials
        , email
        , resetCredentials
        , registerCredentials
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


resetCredentials : Types.ResetCredentials -> String -> String -> JE.Value
resetCredentials credentials uid token =
    JE.object
        [ ( "new_password1", JE.string credentials.password1 )
        , ( "new_password2", JE.string credentials.password2 )
        , ( "uid", JE.string uid )
        , ( "token", JE.string token )
        ]


registerCredentials : Types.RegisterCredentials -> JE.Value
registerCredentials credentials =
    JE.object
        [ ( "username", JE.string credentials.username )
        , ( "email", JE.string credentials.email )
        , ( "password1", JE.string credentials.password1 )
        , ( "password2", JE.string credentials.password2 )
        ]
