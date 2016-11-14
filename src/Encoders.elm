module Encoders
    exposing
        ( credentials
        , email
        , emailConfirmationKey
        , newEmail
        , newProfile
        , newQuestionnaire
        , newSentence
        , newWordSpan
        , passwordCredentials
        , profile
        , recoveryEmail
        , registerCredentials
        , resetCredentials
        , user
        )

import Json.Encode as JE
import Maybe.Extra exposing (unwrap)
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
        [ ( "username", JE.string user'.username )
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
        [ ( "prolific_id", unwrap JE.null JE.string maybeProlific )
        , ( "mothertongue", JE.string "english" )
        ]


profile : Types.Profile -> JE.Value
profile profile' =
    JE.object
        [ ( "prolific_id", unwrap JE.null JE.string profile'.prolificId )
        , ( "mothertongue", JE.string profile'.mothertongue )
        , ( "trained_reformulations", JE.bool profile'.trained )
        , ( "introduced_exp_home", JE.bool profile'.introducedExpHome )
        , ( "introduced_exp_play", JE.bool profile'.introducedExpPlay )
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
        [ ( "email", JE.string email'.email )
        , ( "verified", JE.bool email'.verified )
        , ( "primary", JE.bool email'.primary )
        ]


emailConfirmationKey : String -> JE.Value
emailConfirmationKey key =
    JE.object
        [ ( "key", JE.string key ) ]


newWordSpan : Types.NewWordSpan -> JE.Value
newWordSpan wordSpan =
    JE.object
        [ ( "span", JE.int wordSpan.span )
        , ( "score", JE.int wordSpan.score )
        ]


newQuestionnaire : Types.QuestionnaireForm -> JE.Value
newQuestionnaire questionnaire =
    JE.object
        [ ( "age", JE.string questionnaire.age )
        , ( "gender", JE.string questionnaire.gender )
        , ( "informed", JE.bool questionnaire.informed )
        , ( "informed_how", JE.string questionnaire.informedHow )
        , ( "informed_what", JE.string questionnaire.informedWhat )
        , ( "job_type", JE.string questionnaire.jobType )
        , ( "job_freetext", JE.string questionnaire.jobFreetext )
        ]


newSentence : Types.NewSentence -> JE.Value
newSentence sentence =
    JE.object
        [ ( "text", JE.string sentence.text )
        , ( "language", JE.string sentence.language )
        , ( "bucket", JE.string sentence.bucket )
        , ( "read_time_proportion", JE.float sentence.readTimeProportion )
        , ( "read_time_allotted", JE.float sentence.readTimeAllotted )
        , ( "write_time_proportion", JE.float sentence.writeTimeProportion )
        , ( "write_time_allotted", JE.float sentence.writeTimeAllotted )
        , ( "parent", unwrap JE.null JE.int sentence.parentId )
        ]
