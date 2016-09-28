module Encoders
    exposing
        ( credentials
        , user
        , email
        , recoveryEmail
        , newEmail
        , emailConfirmationKey
        , newProfile
        , resetCredentials
        , registerCredentials
        , passwordCredentials
        )

import Json.Encode as JE
import Maybe.Extra exposing (mapDefault)
import Types


credentials : Types.Credentials -> JE.Value
credentials credentials' =
    JE.object
        [ ( "username", JE.string credentials'.username )
        , ( "password", JE.string credentials'.password )
        ]


user : Types.User -> JE.Value
user user' =
    JE.object
        [ ( "id", JE.int user'.id )
        , ( "username", JE.string user'.username )
        , ( "is_active", JE.bool user'.isActive )
        , ( "is_staff", JE.bool user'.isStaff )
        ]


recoveryEmail : String -> JE.Value
recoveryEmail email' =
    JE.object [ ( "email", JE.string email' ) ]


resetCredentials : Types.ResetCredentials -> Types.ResetTokens -> JE.Value
resetCredentials { password1, password2 } { uid, token } =
    JE.object
        [ ( "new_password1", JE.string password1 )
        , ( "new_password2", JE.string password2 )
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


newProfile : Maybe String -> JE.Value
newProfile maybeProlific =
    JE.object
        [ ( "prolific_id", mapDefault JE.null JE.string maybeProlific )
        , ( "mothertongue", JE.string "english" )
        ]


passwordCredentials : Types.PasswordCredentials -> JE.Value
passwordCredentials { oldPassword, password1, password2 } =
    JE.object
        [ ( "old_password", JE.string oldPassword )
        , ( "new_password1", JE.string password1 )
        , ( "new_password2", JE.string password2 )
        ]


newEmail : String -> JE.Value
newEmail email =
    JE.object
        [ ( "email", JE.string email ) ]


email : Types.Email -> JE.Value
email email' =
    JE.object
        [ ( "id", JE.int email'.id )
        , ( "user", JE.int email'.id )
        , ( "email", JE.string email'.email )
        , ( "verified", JE.bool email'.verified )
        , ( "primary", JE.bool email'.primary )
        ]


emailConfirmationKey : String -> JE.Value
emailConfirmationKey key =
    JE.object
        [ ( "key", JE.string key ) ]
