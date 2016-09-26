module Api
    exposing
        ( authCall
        , call
        , createProfile
        , getUser
        , login
        , logout
        , recover
        , reset
        , register
        )

import Decoders
import Dict
import Encoders
import HttpBuilder exposing (RequestBuilder)
import Msg exposing (Msg(..))
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


badOr : (String -> a) -> HttpBuilder.Error a -> a
badOr default error =
    case error of
        HttpBuilder.BadResponse response ->
            response.data

        _ ->
            default (toString error)



-- LOGIN


login : Types.Credentials -> Cmd Msg
login credentials =
    let
        task =
            call HttpBuilder.post "/rest-auth/login/"
                |> HttpBuilder.withJsonBody (Encoders.credentials credentials)
                |> HttpBuilder.send
                    (HttpBuilder.jsonReader Decoders.token)
                    (HttpBuilder.jsonReader (Decoders.feedback loginFeedbackFields))
    in
        Task.perform
            (badOr Types.globalFeedback >> LoginFail)
            (.data >> GotToken Nothing)
            task


loginFeedbackFields : Dict.Dict String String
loginFeedbackFields =
    Dict.fromList
        [ ( "username", "username" )
        , ( "password", "password" )
        , ( "non_field_errors", "global" )
        ]


getUser : Maybe String -> Types.Token -> Cmd Msg
getUser maybeProlific token =
    let
        task =
            authCall HttpBuilder.get "/users/me/" token
                |> HttpBuilder.send
                    (HttpBuilder.jsonReader Decoders.user)
                    (HttpBuilder.jsonReader Decoders.detail)
    in
        Task.perform
            (badOr identity >> Types.globalFeedback >> GetUserFail)
            (.data >> GotUser maybeProlific token)
            task



-- REGISTER


register : Maybe String -> Types.RegisterCredentials -> Cmd Msg
register maybeProlific credentials =
    let
        task =
            call HttpBuilder.post "/rest-auth/registration/"
                |> HttpBuilder.withJsonBody (Encoders.registerCredentials credentials)
                |> HttpBuilder.send
                    (HttpBuilder.jsonReader Decoders.token)
                    (HttpBuilder.jsonReader (Decoders.feedback registerFeedbackFields))
    in
        Task.perform
            (badOr Types.globalFeedback >> RegisterFail)
            (.data >> GotToken maybeProlific)
            task


registerFeedbackFields : Dict.Dict String String
registerFeedbackFields =
    Dict.fromList
        [ ( "username", "username" )
        , ( "email", "email" )
        , ( "password1", "password1" )
        , ( "password2", "password2" )
        , ( "__all__", "global" )
        ]


createProfile : Types.User -> Maybe String -> String -> Cmd Msg
createProfile user maybeProlific token =
    let
        task =
            authCall HttpBuilder.post "/profiles/" token
                |> HttpBuilder.withJsonBody (Encoders.newProfile maybeProlific)
                |> HttpBuilder.send
                    (HttpBuilder.jsonReader Decoders.profile)
                    (HttpBuilder.jsonReader Decoders.detail)
    in
        Task.perform
            (badOr identity >> Error)
            (.data >> CreatedProfile token user)
            task



-- LOGOUT


logout : Types.Token -> Cmd Msg
logout token =
    let
        task =
            authCall HttpBuilder.post "/rest-auth/logout/" token
                |> HttpBuilder.send
                    (always (Ok ()))
                    (HttpBuilder.jsonReader Decoders.detail)
    in
        Task.perform
            (badOr identity >> LogoutFail)
            (always LogoutSuccess)
            task



-- RECOVER


recover : String -> Cmd Msg
recover email =
    let
        task =
            call HttpBuilder.post "/rest-auth/password/reset/"
                |> HttpBuilder.withJsonBody (Encoders.email email)
                |> HttpBuilder.send
                    (always (Ok ()))
                    (HttpBuilder.jsonReader (Decoders.feedback recoverFeedbackFields))
    in
        Task.perform
            (badOr Types.globalFeedback >> RecoverFail)
            (always RecoverSuccess)
            task


recoverFeedbackFields : Dict.Dict String String
recoverFeedbackFields =
    Dict.fromList
        [ ( "email", "global" )
        ]



-- RESET


reset : Types.ResetCredentials -> String -> String -> Cmd Msg
reset credentials uid token =
    let
        task =
            call HttpBuilder.post "/rest-auth/password/reset/confirm/"
                |> HttpBuilder.withJsonBody (Encoders.resetCredentials credentials uid token)
                |> HttpBuilder.send
                    (always (Ok ()))
                    (HttpBuilder.jsonReader (Decoders.feedback resetFeedbackFields))
    in
        Task.perform
            (badOr Types.globalFeedback >> translateResetFeedback >> ResetFail)
            (always ResetSuccess)
            task


resetFeedbackFields : Dict.Dict String String
resetFeedbackFields =
    Dict.fromList
        [ ( "new_password1", "password1" )
        , ( "new_password2", "password2" )
        , ( "token", "resetCredentials" )
        , ( "uid", "resetCredentials" )
        ]


translateResetFeedback : Types.Feedback -> Types.Feedback
translateResetFeedback feedback =
    feedback
        |> Dict.update "resetCredentials" (Maybe.map (always "There was a problem. Did you use the last password-reset link you received?"))
