module Api
    exposing
        ( addEmail
        , changePassword
        , confirmEmail
        , deleteEmail
        , fetch
        , fetchAuth
        , fetchMeta
        , login
        , logout
        , postQuestionnaire
        , recover
        , register
        , requestEmailVerification
        , reset
        , updateEmail
        , updateUser
        )

import Decoders
import Dict
import Encoders
import Feedback
import HttpBuilder exposing (RequestBuilder)
import Store
import Task
import Types


-- CONFIG


baseUrl : String
baseUrl =
    "//127.0.0.1:8000/api"



-- GENERIC CALLS


call : (String -> RequestBuilder) -> String -> RequestBuilder
call method url =
    method (baseUrl ++ url)
        |> HttpBuilder.withHeader "Content-Type" "application/json"
        |> HttpBuilder.withHeader "Accept" "application/json"


authCall : (String -> RequestBuilder) -> String -> Types.Token -> RequestBuilder
authCall method url token =
    call method url
        |> HttpBuilder.withHeader "Authorization" ("Token " ++ token)


errorAs :
    (a -> b)
    -> (String -> b)
    -> HttpBuilder.Error a
    -> b
errorAs format default error =
    case error of
        HttpBuilder.BadResponse response ->
            format response.data

        _ ->
            default (toString error)



-- LOGIN


login : Types.Credentials -> Task.Task Types.Error Types.Auth
login credentials =
    let
        getToken =
            call HttpBuilder.post "/rest-auth/login/"
                |> HttpBuilder.withJsonBody (Encoders.credentials credentials)
                |> HttpBuilder.send
                    (HttpBuilder.jsonReader Decoders.token)
                    (HttpBuilder.jsonReader (Decoders.feedback loginFeedbackFields))
                |> Task.mapError (errorAs Types.ApiFeedback Types.Unrecoverable)
                |> Task.map .data
    in
        getToken `Task.andThen` fetchAuth


loginFeedbackFields : Dict.Dict String String
loginFeedbackFields =
    Dict.fromList
        [ ( "username", "username" )
        , ( "password", "password" )
        , ( "non_field_errors", "global" )
        ]



-- USER AND PROFILE


fetchAuth : Types.Token -> Task.Task Types.Error Types.Auth
fetchAuth token =
    fetchAuthSettingProfile Nothing token


fetchAuthSettingProfile : Maybe String -> Types.Token -> Task.Task Types.Error Types.Auth
fetchAuthSettingProfile maybeProlific token =
    Types.Auth token `Task.map` (fetchUserSettingProfile maybeProlific token)


fetchUser : Types.Token -> Task.Task Types.Error Types.User
fetchUser token =
    fetchUserSettingProfile Nothing token


fetchUserSettingProfile : Maybe String -> Types.Token -> Task.Task Types.Error Types.User
fetchUserSettingProfile maybeProlific token =
    fetchPreUser token
        `Task.andThen`
            \preUser ->
                case preUser.profile of
                    Just profile ->
                        Task.succeed { preUser | profile = profile }

                    Nothing ->
                        createProfile maybeProlific { token = token, preUser = preUser }


fetchPreUser : Types.Token -> Task.Task Types.Error Types.PreUser
fetchPreUser token =
    authCall HttpBuilder.get "/users/me/" token
        |> HttpBuilder.send
            (HttpBuilder.jsonReader Decoders.preUser)
            HttpBuilder.stringReader
        |> Task.mapError (errorAs Types.Unrecoverable Types.Unrecoverable)
        |> Task.map .data


createProfile :
    Maybe String
    -> { token : Types.Token, preUser : Types.PreUser }
    -> Task.Task Types.Error Types.User
createProfile maybeProlific { token, preUser } =
    authCall HttpBuilder.post "/profiles/" token
        |> HttpBuilder.withJsonBody (Encoders.newProfile maybeProlific)
        |> HttpBuilder.send
            (HttpBuilder.jsonReader Decoders.profile)
            HttpBuilder.stringReader
        |> Task.mapError (errorAs Types.Unrecoverable Types.Unrecoverable)
        |> Task.map (.data >> \p -> { preUser | profile = p })



-- REGISTER


register : Maybe String -> Types.RegisterCredentials -> Task.Task Types.Error Types.Auth
register maybeProlific credentials =
    let
        createToken =
            call HttpBuilder.post "/rest-auth/registration/"
                |> HttpBuilder.withJsonBody (Encoders.registerCredentials credentials)
                |> HttpBuilder.send
                    (HttpBuilder.jsonReader Decoders.token)
                    (HttpBuilder.jsonReader (Decoders.feedback registerFeedbackFields))
                |> Task.mapError (errorAs Types.ApiFeedback Types.Unrecoverable)
                |> Task.map .data
    in
        createToken `Task.andThen` (fetchAuthSettingProfile maybeProlific)


registerFeedbackFields : Dict.Dict String String
registerFeedbackFields =
    Dict.fromList
        [ ( "username", "username" )
        , ( "email", "email" )
        , ( "password1", "password1" )
        , ( "password2", "password2" )
        , ( "__all__", "global" )
        ]



-- LOGOUT


logout : Types.Auth -> Task.Task Types.Error ()
logout { token } =
    authCall HttpBuilder.post "/rest-auth/logout/" token
        |> HttpBuilder.send
            (always (Ok ()))
            HttpBuilder.stringReader
        |> Task.mapError (errorAs Types.Unrecoverable Types.Unrecoverable)
        |> Task.map .data



-- RECOVER


recover : String -> Task.Task Types.Error ()
recover email =
    call HttpBuilder.post "/rest-auth/password/reset/"
        |> HttpBuilder.withJsonBody (Encoders.recoveryEmail email)
        |> HttpBuilder.send
            (always (Ok ()))
            (HttpBuilder.jsonReader (Decoders.feedback recoverFeedbackFields))
        |> Task.mapError (errorAs Types.ApiFeedback Types.Unrecoverable)
        |> Task.map .data


recoverFeedbackFields : Dict.Dict String String
recoverFeedbackFields =
    Dict.fromList
        [ ( "email", "global" ) ]



-- RESET


reset : Types.ResetCredentials -> Types.ResetTokens -> Task.Task Types.Error ()
reset credentials tokens =
    call HttpBuilder.post "/rest-auth/password/reset/confirm/"
        |> HttpBuilder.withJsonBody (Encoders.resetCredentials credentials tokens)
        |> HttpBuilder.send
            (always (Ok ()))
            (HttpBuilder.jsonReader (Decoders.feedback resetFeedbackFields))
        |> Task.mapError (errorAs (translateResetFeedback >> Types.ApiFeedback) Types.Unrecoverable)
        |> Task.map .data


resetFeedbackFields : Dict.Dict String String
resetFeedbackFields =
    Dict.fromList
        [ ( "new_password1", "password1" )
        , ( "new_password2", "password2" )
        , ( "token", "resetCredentials" )
        , ( "uid", "resetCredentials" )
        ]


translateResetFeedback : Feedback.Feedback -> Feedback.Feedback
translateResetFeedback feedback =
    Feedback.updateError "resetCredentials"
        (Just
            ("There was a problem. Did you use the"
                ++ " last password-reset link you received?"
            )
        )
        feedback



-- USER


updateUser : Types.User -> Types.Auth -> Task.Task Types.Error Types.User
updateUser user { token } =
    authCall HttpBuilder.put ("/users/" ++ (toString user.id) ++ "/") token
        |> HttpBuilder.withJsonBody (Encoders.user user)
        |> HttpBuilder.send
            (HttpBuilder.jsonReader Decoders.user)
            (HttpBuilder.jsonReader (Decoders.feedback usernameChangeFeedbackFields))
        |> Task.mapError (errorAs Types.ApiFeedback Types.Unrecoverable)
        |> Task.map .data


usernameChangeFeedbackFields : Dict.Dict String String
usernameChangeFeedbackFields =
    Dict.fromList
        [ ( "username", "global" ) ]



-- PASSWORD CHANGE


changePassword : Types.PasswordCredentials -> Types.Auth -> Task.Task Types.Error Types.Auth
changePassword credentials auth =
    let
        loginCredentials =
            { username = auth.user.username, password = credentials.password1 }

        postPassword =
            authCall HttpBuilder.post "/rest-auth/password/change/" auth.token
                |> HttpBuilder.withJsonBody (Encoders.passwordCredentials credentials)
                |> HttpBuilder.send
                    (always (Ok ()))
                    (HttpBuilder.jsonReader (Decoders.feedback passwordChangeFeedbackFields))
                |> Task.mapError (errorAs Types.ApiFeedback Types.Unrecoverable)
                |> Task.map .data
    in
        postPassword
            `Task.andThen` (always <| logout auth)
            `Task.andThen` (always <| login loginCredentials)


passwordChangeFeedbackFields : Dict.Dict String String
passwordChangeFeedbackFields =
    Dict.fromList
        [ ( "old_password", "oldPassword" )
        , ( "new_password1", "password1" )
        , ( "new_password2", "password2" )
        ]



-- EMAILS


addEmail : String -> Types.Auth -> Task.Task Types.Error Types.User
addEmail email { token } =
    let
        postEmail =
            authCall HttpBuilder.post "/emails/" token
                |> HttpBuilder.withJsonBody (Encoders.newEmail email)
                |> HttpBuilder.send
                    (always (Ok ()))
                    (HttpBuilder.jsonReader (Decoders.feedback addEmailFeedbackFields))
                |> Task.mapError (errorAs Types.ApiFeedback Types.Unrecoverable)
                |> Task.map .data
    in
        postEmail `Task.andThen` (always <| fetchUser token)


addEmailFeedbackFields : Dict.Dict String String
addEmailFeedbackFields =
    Dict.fromList [ ( "email", "global" ) ]


requestEmailVerification : Types.Email -> Types.Auth -> Task.Task Types.Error ()
requestEmailVerification email { token } =
    authCall HttpBuilder.post ("/emails/" ++ (toString email.id) ++ "/verify/") token
        |> HttpBuilder.send
            (always (Ok ()))
            HttpBuilder.stringReader
        |> Task.mapError (errorAs Types.Unrecoverable Types.Unrecoverable)
        |> Task.map .data


updateEmail : Types.Email -> Types.Auth -> Task.Task Types.Error Types.User
updateEmail email { token } =
    let
        putEmail =
            authCall HttpBuilder.put ("/emails/" ++ (toString email.id) ++ "/") token
                |> HttpBuilder.withJsonBody (Encoders.email email)
                |> HttpBuilder.send
                    (always (Ok ()))
                    HttpBuilder.stringReader
                |> Task.mapError (errorAs Types.Unrecoverable Types.Unrecoverable)
                |> Task.map .data
    in
        putEmail `Task.andThen` (always <| fetchUser token)


deleteEmail : Types.Email -> Types.Auth -> Task.Task Types.Error Types.User
deleteEmail email { token } =
    let
        delete =
            authCall HttpBuilder.delete ("/emails/" ++ (toString email.id) ++ "/") token
                |> HttpBuilder.send
                    (always (Ok ()))
                    HttpBuilder.stringReader
                |> Task.mapError (errorAs Types.Unrecoverable Types.Unrecoverable)
                |> Task.map .data
    in
        delete `Task.andThen` (always <| fetchUser token)


confirmEmail : String -> Types.Auth -> Task.Task Types.Error Types.User
confirmEmail key { token } =
    let
        confirm =
            call HttpBuilder.post "/rest-auth/registration/verify-email/"
                |> HttpBuilder.withJsonBody (Encoders.emailConfirmationKey key)
                |> HttpBuilder.send
                    (always (Ok ()))
                    (HttpBuilder.jsonReader Decoders.detail)
                |> Task.mapError
                    (errorAs (Feedback.globalError >> Types.ApiFeedback) Types.Unrecoverable)
                |> Task.map .data
    in
        confirm `Task.andThen` (always <| fetchUser token)



-- STORE


fetch : Store.TypedStore a b -> Int -> Types.Auth -> Task.Task Types.Error a
fetch typedStore id { token } =
    authCall HttpBuilder.get ("/" ++ (Store.endpoint typedStore) ++ "/" ++ (toString id) ++ "/") token
        |> HttpBuilder.send
            (HttpBuilder.jsonReader (Store.decoder typedStore))
            HttpBuilder.stringReader
        |> Task.mapError (errorAs Types.Unrecoverable Types.Unrecoverable)
        |> Task.map .data



-- META


fetchMeta : Task.Task Types.Error Types.Meta
fetchMeta =
    call HttpBuilder.get "/meta/"
        |> HttpBuilder.send
            (HttpBuilder.jsonReader Decoders.meta)
            HttpBuilder.stringReader
        |> Task.mapError (errorAs Types.Unrecoverable Types.Unrecoverable)
        |> Task.map .data



-- QUESTIONNAIRE


postQuestionnaire : Types.QuestionnaireForm -> Types.Auth -> Task.Task Types.Error Types.User
postQuestionnaire questionnaire { token } =
    let
        postQuestionnaire =
            authCall HttpBuilder.post "/questionnaires/" token
                |> HttpBuilder.withJsonBody (Encoders.newQuestionnaire questionnaire)
                |> HttpBuilder.send
                    (always (Ok ()))
                    (HttpBuilder.jsonReader (Decoders.feedback postQuestionnaireFeedbackFields))
                |> Task.mapError (errorAs Types.ApiFeedback Types.Unrecoverable)
                |> Task.map .data
    in
        postQuestionnaire `Task.andThen` (always <| fetchUser token)


postQuestionnaireFeedbackFields : Dict.Dict String String
postQuestionnaireFeedbackFields =
    Dict.fromList
        [ ( "age", "age" )
        , ( "gender", "gender" )
        , ( "informed_how", "informedHow" )
        , ( "informed_what", "informedWhat" )
        , ( "job_type", "jobType" )
        , ( "job_freetext", "jobFreetext" )
        ]
