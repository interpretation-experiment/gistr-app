module Api.Calls
    exposing
        ( ApiTask
        , andThen
        , deleteEmail
        , getMeta
        , getPreUser
        , getProfile
        , getProfiles
        , getSentence
        , getSentences
        , getTree
        , getTrees
        , getWordSpan
        , map
        , map2
        , postEmail
        , postEmailConfirm
        , postEmailVerify
        , postLogin
        , postLogout
        , postPassword
        , postProfile
        , postQuestionnaire
        , postRecovery
        , postRegister
        , postReset
        , postSentence
        , putEmail
        , putProfile
        , putUser
        , succeed
        )

import Decoders
import Encoders
import Feedback
import Http
import HttpBuilder exposing (RequestBuilder)
import Json.Decode as JD
import Json.Encode as JE
import Maybe.Extra exposing (unwrap)
import Task
import Types


-- CONFIG: TODO: move to a Config.elm with other config values


baseUrl : String
baseUrl =
    "//127.0.0.1:8000/api"



-- CALL BUILDING


type alias ApiTask a =
    Task.Task Http.Error (Result Feedback.Feedback a)


succeed : a -> ApiTask a
succeed =
    Task.succeed << Ok


andThen : (a -> ApiTask b) -> ApiTask a -> ApiTask b
andThen thenTask task =
    let
        okNext result =
            case result of
                Ok value ->
                    thenTask value

                Err error ->
                    Task.succeed (Err error)
    in
        task |> Task.andThen okNext


map : (a -> b) -> ApiTask a -> ApiTask b
map func =
    Task.map (Result.map func)


map2 : (a -> b -> c) -> ApiTask a -> ApiTask b -> ApiTask c
map2 func =
    Task.map2 (Result.map2 func)


expectNothing : Http.Expect ()
expectNothing =
    Http.expectStringResponse (always <| Ok ())


pageQuery : Maybe { pageSize : Int, page : Int } -> List ( String, String )
pageQuery maybePage =
    case maybePage of
        Nothing ->
            []

        Just { pageSize, page } ->
            [ ( "page_size", toString pageSize )
            , ( "page", toString page )
            ]


builder :
    { method : String -> RequestBuilder ()
    , path : String
    , query : List ( String, String )
    , token : Maybe Types.Token
    , expect : Http.Expect a
    }
    -> RequestBuilder a
builder { method, path, query, token, expect } =
    method (baseUrl ++ path)
        |> HttpBuilder.withQueryParams query
        |> HttpBuilder.withHeader "Accept" "application/json"
        |> unwrap identity (HttpBuilder.withHeader "Authorization" << (++) "Token ") token
        |> HttpBuilder.withExpect expect


extractFeedback : List ( String, String ) -> Http.Error -> ApiTask a
extractFeedback fields error =
    case error of
        Http.BadStatus response ->
            case JD.decodeString (Decoders.feedback fields) response.body of
                Ok feedback ->
                    Task.succeed (Err feedback)

                Err _ ->
                    Task.fail error

        _ ->
            Task.fail error


finalize : List ( String, String ) -> RequestBuilder a -> ApiTask a
finalize feedback builder =
    builder
        |> HttpBuilder.toRequest
        |> Http.toTask
        |> Task.map Ok
        |> Task.onError (extractFeedback feedback)


get :
    { path : String
    , query : List ( String, String )
    , token : Maybe Types.Token
    , expect : Http.Expect a
    }
    -> ApiTask a
get { path, query, token, expect } =
    builder
        { method = HttpBuilder.get
        , path = path
        , query = query
        , token = token
        , expect = expect
        }
        |> finalize []


post :
    { path : String
    , query : List ( String, String )
    , token : Maybe Types.Token
    , body : Maybe JE.Value
    , expect : Http.Expect a
    , feedback : List ( String, String )
    }
    -> ApiTask a
post { path, query, token, body, expect, feedback } =
    builder
        { method = HttpBuilder.post
        , path = path
        , query = query
        , token = token
        , expect = expect
        }
        |> unwrap identity HttpBuilder.withJsonBody body
        |> finalize feedback


put :
    { path : String
    , query : List ( String, String )
    , token : Maybe Types.Token
    , body : Maybe JE.Value
    , expect : Http.Expect a
    , feedback : List ( String, String )
    }
    -> ApiTask a
put { path, query, token, body, expect, feedback } =
    builder
        { method = HttpBuilder.put
        , path = path
        , query = query
        , token = token
        , expect = expect
        }
        |> unwrap identity HttpBuilder.withJsonBody body
        |> finalize feedback


delete :
    { path : String
    , query : List ( String, String )
    , token : Maybe Types.Token
    , expect : Http.Expect a
    }
    -> ApiTask a
delete { path, query, token, expect } =
    builder
        { method = HttpBuilder.delete
        , path = path
        , query = query
        , token = token
        , expect = expect
        }
        |> finalize []



-- TOKEN


postLogin : Types.Credentials -> ApiTask Types.Token
postLogin credentials =
    post
        { path = "/rest-auth/login/"
        , query = []
        , token = Nothing
        , body = Just <| Encoders.credentials credentials
        , expect = Http.expectJson Decoders.token
        , feedback =
            [ ( "username", "username" )
            , ( "password", "password" )
            , ( "non_field_errors", "global" )
            ]
        }


postRegister : Types.RegisterCredentials -> ApiTask Types.Token
postRegister credentials =
    post
        { path = "/rest-auth/registration/"
        , query = []
        , token = Nothing
        , body = Just <| Encoders.registerCredentials credentials
        , expect = Http.expectJson Decoders.token
        , feedback =
            [ ( "username", "username" )
            , ( "email", "email" )
            , ( "password1", "password1" )
            , ( "password2", "password2" )
            , ( "__all__", "global" )
            ]
        }


postLogout : Types.Auth -> ApiTask ()
postLogout { token } =
    post
        { path = "/rest-auth/logout/"
        , query = []
        , token = Just token
        , body = Nothing
        , expect = expectNothing
        , feedback = []
        }



-- PASSWORD


postRecovery : String -> ApiTask ()
postRecovery email =
    post
        { path = "/rest-auth/password/reset/"
        , query = []
        , token = Nothing
        , body = Just <| Encoders.recoveryEmail email
        , expect = expectNothing
        , feedback = [ ( "email", "global" ) ]
        }


postReset : Types.ResetTokens -> Types.ResetCredentials -> ApiTask ()
postReset tokens credentials =
    let
        transpose =
            -- TODO: move to Strings.elm
            "There was a problem. Did you use the"
                ++ " last password-reset link you received?"
                |> Just
                |> Feedback.updateError "resetCredentials"
    in
        post
            { path = "/rest-auth/password/reset/confirm/"
            , query = []
            , token = Nothing
            , body = Just <| Encoders.resetCredentials credentials tokens
            , expect = expectNothing
            , feedback =
                [ ( "new_password1", "password1" )
                , ( "new_password2", "password2" )
                , ( "token", "resetCredentials" )
                , ( "uid", "resetCredentials" )
                ]
            }
            |> Task.map (Result.mapError transpose)


postPassword : Types.Auth -> Types.PasswordCredentials -> ApiTask ()
postPassword { token } credentials =
    post
        { path = "/rest-auth/password/change/"
        , query = []
        , token = Just token
        , body = Just <| Encoders.passwordCredentials credentials
        , expect = expectNothing
        , feedback =
            [ ( "old_password", "oldPassword" )
            , ( "new_password1", "password1" )
            , ( "new_password2", "password2" )
            ]
        }



-- USER


getPreUser : Types.Token -> ApiTask Types.PreUser
getPreUser token =
    get
        { path = "/users/me/"
        , query = []
        , token = Just token
        , expect = Http.expectJson Decoders.preUser
        }


putUser : Types.Auth -> Types.User -> ApiTask Types.User
putUser { token } user =
    put
        { path = "/users/" ++ (toString user.id) ++ "/"
        , query = []
        , token = Just token
        , body = Just <| Encoders.user user
        , expect = Http.expectJson Decoders.user
        , feedback = [ ( "username", "global" ) ]
        }



-- PROFILE


getProfile : Types.Auth -> Int -> ApiTask Types.Profile
getProfile { token } id =
    get
        { path = "/profiles/" ++ (toString id) ++ "/"
        , query = []
        , token = Just token
        , expect = Http.expectJson Decoders.profile
        }


getProfiles :
    Types.Auth
    -> Maybe { pageSize : Int, page : Int }
    -> List ( String, String )
    -> ApiTask (Types.Page Types.Profile)
getProfiles { token } maybePage query =
    get
        { path = "/profiles/"
        , query = query ++ (pageQuery maybePage)
        , token = Just token
        , expect = Http.expectJson (Decoders.page Decoders.profile)
        }


postProfile :
    { token : Types.Token, preUser : Types.PreUser }
    -> Maybe String
    -> ApiTask Types.Profile
postProfile { token, preUser } maybeProlific =
    post
        { path = "/profiles/"
        , query = []
        , token = Just token
        , body = Just <| Encoders.newProfile maybeProlific
        , expect = Http.expectJson Decoders.profile
        , feedback = []
        }


putProfile : Types.Auth -> Types.Profile -> ApiTask Types.Profile
putProfile { token } profile =
    put
        { path = "/profiles/" ++ (toString profile.id) ++ "/"
        , query = []
        , token = Just token
        , body = Just <| Encoders.profile profile
        , expect = Http.expectJson Decoders.profile
        , feedback = []
        }



-- META


getMeta : ApiTask Types.Meta
getMeta =
    get
        { path = "/meta/"
        , query = []
        , token = Nothing
        , expect = Http.expectJson Decoders.meta
        }



-- EMAIL


postEmail : Types.Auth -> String -> ApiTask ()
postEmail { token } email =
    post
        { path = "/emails/"
        , query = []
        , token = Just token
        , body = Just <| Encoders.newEmail email
        , expect = expectNothing
        , feedback = [ ( "email", "global" ) ]
        }


putEmail : Types.Auth -> Types.Email -> ApiTask ()
putEmail { token } email =
    put
        { path = "/emails/" ++ (toString email.id) ++ "/"
        , query = []
        , token = Just token
        , body = Just <| Encoders.email email
        , expect = expectNothing
        , feedback = []
        }


deleteEmail : Types.Auth -> Types.Email -> ApiTask ()
deleteEmail { token } email =
    delete
        { path = "/emails/" ++ (toString email.id) ++ "/"
        , query = []
        , token = Just token
        , expect = expectNothing
        }


postEmailVerify : Types.Auth -> Types.Email -> ApiTask ()
postEmailVerify { token } email =
    post
        { path = "/emails/" ++ (toString email.id) ++ "/verify/"
        , query = []
        , token = Just token
        , body = Nothing
        , expect = expectNothing
        , feedback = []
        }


postEmailConfirm : Types.Auth -> String -> ApiTask ()
postEmailConfirm { token } key =
    post
        { path = "/rest-auth/registration/verify-email/"
        , query = []
        , token = Just token
        , body = Just <| Encoders.emailConfirmationKey key
        , expect = expectNothing
        , feedback = [ ( "detail", "global" ) ]
        }



-- QUESTIONNAIRE


postQuestionnaire : Types.Auth -> Types.QuestionnaireForm -> ApiTask ()
postQuestionnaire { token } questionnaire =
    post
        { path = "/questionnaires/"
        , query = []
        , token = Just token
        , body = Just <| Encoders.newQuestionnaire questionnaire
        , expect = expectNothing
        , feedback =
            [ ( "age", "age" )
            , ( "gender", "gender" )
            , ( "informed_how", "informedHow" )
            , ( "informed_what", "informedWhat" )
            , ( "job_type", "jobType" )
            , ( "job_freetext", "jobFreetext" )
            ]
        }



-- WORD SPAN


getWordSpan : Types.Auth -> Int -> ApiTask Types.WordSpan
getWordSpan { token } id =
    get
        { path = "/word-spans/" ++ (toString id) ++ "/"
        , query = []
        , token = Just token
        , expect = Http.expectJson Decoders.wordSpan
        }



-- SENTENCE


getSentence : Types.Auth -> Int -> ApiTask Types.Sentence
getSentence { token } id =
    get
        { path = "/sentences/" ++ (toString id) ++ "/"
        , query = []
        , token = Just token
        , expect = Http.expectJson Decoders.sentence
        }


getSentences :
    Types.Auth
    -> Maybe { pageSize : Int, page : Int }
    -> List ( String, String )
    -> ApiTask (Types.Page Types.Sentence)
getSentences { token } maybePage query =
    get
        { path = "/sentences/"
        , query = query ++ (pageQuery maybePage)
        , token = Just token
        , expect = Http.expectJson (Decoders.page Decoders.sentence)
        }


postSentence : Types.Auth -> Types.NewSentence -> ApiTask ()
postSentence { token } sentence =
    post
        { path = "/sentences/"
        , query = []
        , token = Just token
        , body = Just <| Encoders.newSentence sentence
        , expect = expectNothing
        , feedback = []
        }



-- TREE


getTree : Types.Auth -> Int -> ApiTask Types.Tree
getTree { token } id =
    get
        { path = "/trees/" ++ (toString id) ++ "/"
        , query = []
        , token = Just token
        , expect = Http.expectJson Decoders.tree
        }


getTrees :
    Types.Auth
    -> Maybe { pageSize : Int, page : Int }
    -> List ( String, String )
    -> ApiTask (Types.Page Types.Tree)
getTrees { token } maybePage query =
    get
        { path = "/trees/"
        , query = query ++ (pageQuery maybePage)
        , token = Just token
        , expect = Http.expectJson (Decoders.page Decoders.tree)
        }
