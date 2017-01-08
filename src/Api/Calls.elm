module Api.Calls
    exposing
        ( Task
        , deleteEmail
        , getMeta
        , getPreUser
        , getProfile
        , getProfiles
        , getSentence
        , getSentences
        , getServedTree
        , getTree
        , getTrees
        , getWordSpan
        , postComment
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
        )

import Config
import Decoders
import Encoders
import Http
import HttpBuilder exposing (RequestBuilder)
import Json.Decode as JD
import Json.Encode as JE
import Maybe.Extra exposing (unwrap)
import Task
import Types


-- CALL BUILDING


type alias Task a =
    Task.Task Types.Error a


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
    method (Config.baseUrl ++ path)
        |> HttpBuilder.withQueryParams query
        |> HttpBuilder.withHeader "Accept" "application/json"
        |> unwrap identity (HttpBuilder.withHeader "Authorization" << (++) "Token ") token
        |> HttpBuilder.withExpect expect


toTask : RequestBuilder a -> Task a
toTask builder =
    builder
        |> HttpBuilder.toTask
        |> Task.mapError Types.HttpError


get :
    { path : String
    , query : List ( String, String )
    , token : Maybe Types.Token
    , expect : Http.Expect a
    }
    -> Task a
get { path, query, token, expect } =
    builder
        { method = HttpBuilder.get
        , path = path
        , query = query
        , token = token
        , expect = expect
        }
        |> toTask


post :
    { path : String
    , query : List ( String, String )
    , token : Maybe Types.Token
    , body : Maybe JE.Value
    , expect : Http.Expect a
    }
    -> Task a
post { path, query, token, body, expect } =
    builder
        { method = HttpBuilder.post
        , path = path
        , query = query
        , token = token
        , expect = expect
        }
        |> unwrap identity HttpBuilder.withJsonBody body
        |> toTask


put :
    { path : String
    , query : List ( String, String )
    , token : Maybe Types.Token
    , body : Maybe JE.Value
    , expect : Http.Expect a
    }
    -> Task a
put { path, query, token, body, expect } =
    builder
        { method = HttpBuilder.put
        , path = path
        , query = query
        , token = token
        , expect = expect
        }
        |> unwrap identity HttpBuilder.withJsonBody body
        |> toTask


delete :
    { path : String
    , query : List ( String, String )
    , token : Maybe Types.Token
    , expect : Http.Expect a
    }
    -> Task a
delete { path, query, token, expect } =
    builder
        { method = HttpBuilder.delete
        , path = path
        , query = query
        , token = token
        , expect = expect
        }
        |> toTask



-- TOKEN


postLogin : Types.Credentials -> Task Types.Token
postLogin credentials =
    post
        { path = "/rest-auth/login/"
        , query = []
        , token = Nothing
        , body = Just <| Encoders.credentials credentials
        , expect = Http.expectJson Decoders.token
        }


postRegister : Types.RegisterCredentials -> Task Types.Token
postRegister credentials =
    post
        { path = "/rest-auth/registration/"
        , query = []
        , token = Nothing
        , body = Just <| Encoders.registerCredentials credentials
        , expect = Http.expectJson Decoders.token
        }


postLogout : Types.Auth -> Task ()
postLogout { token } =
    post
        { path = "/rest-auth/logout/"
        , query = []
        , token = Just token
        , body = Nothing
        , expect = expectNothing
        }



-- PASSWORD


postRecovery : String -> Task ()
postRecovery email =
    post
        { path = "/rest-auth/password/reset/"
        , query = []
        , token = Nothing
        , body = Just <| Encoders.recoveryEmail email
        , expect = expectNothing
        }


postReset : Types.ResetTokens -> Types.ResetCredentials -> Task ()
postReset tokens credentials =
    post
        { path = "/rest-auth/password/reset/confirm/"
        , query = []
        , token = Nothing
        , body = Just <| Encoders.resetCredentials credentials tokens
        , expect = expectNothing
        }


postPassword : Types.Auth -> Types.PasswordCredentials -> Task ()
postPassword { token } credentials =
    post
        { path = "/rest-auth/password/change/"
        , query = []
        , token = Just token
        , body = Just <| Encoders.passwordCredentials credentials
        , expect = expectNothing
        }



-- USER


getPreUser : Types.Token -> Task Types.PreUser
getPreUser token =
    get
        { path = "/users/me/"
        , query = []
        , token = Just token
        , expect = Http.expectJson Decoders.preUser
        }


putUser : Types.Auth -> Types.User -> Task Types.User
putUser { token } user =
    put
        { path = "/users/" ++ (toString user.id) ++ "/"
        , query = []
        , token = Just token
        , body = Just <| Encoders.user user
        , expect = Http.expectJson Decoders.user
        }



-- PROFILE


getProfile : Types.Auth -> Int -> Task Types.Profile
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
    -> Task (Types.Page Types.Profile)
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
    -> Task Types.Profile
postProfile { token, preUser } maybeProlific =
    post
        { path = "/profiles/"
        , query = []
        , token = Just token
        , body = Just <| Encoders.newProfile maybeProlific
        , expect = Http.expectJson Decoders.profile
        }


putProfile : Types.Auth -> Types.Profile -> Task Types.Profile
putProfile { token } profile =
    put
        { path = "/profiles/" ++ (toString profile.id) ++ "/"
        , query = []
        , token = Just token
        , body = Just <| Encoders.profile profile
        , expect = Http.expectJson Decoders.profile
        }



-- META


getMeta : Task Types.Meta
getMeta =
    get
        { path = "/meta/"
        , query = []
        , token = Nothing
        , expect = Http.expectJson Decoders.meta
        }



-- EMAIL


postEmail : Types.Auth -> String -> Task ()
postEmail { token } email =
    post
        { path = "/emails/"
        , query = []
        , token = Just token
        , body = Just <| Encoders.newEmail email
        , expect = expectNothing
        }


putEmail : Types.Auth -> Types.Email -> Task ()
putEmail { token } email =
    put
        { path = "/emails/" ++ (toString email.id) ++ "/"
        , query = []
        , token = Just token
        , body = Just <| Encoders.email email
        , expect = expectNothing
        }


deleteEmail : Types.Auth -> Types.Email -> Task ()
deleteEmail { token } email =
    delete
        { path = "/emails/" ++ (toString email.id) ++ "/"
        , query = []
        , token = Just token
        , expect = expectNothing
        }


postEmailVerify : Types.Auth -> Types.Email -> Task ()
postEmailVerify { token } email =
    post
        { path = "/emails/" ++ (toString email.id) ++ "/verify/"
        , query = []
        , token = Just token
        , body = Nothing
        , expect = expectNothing
        }


postEmailConfirm : Types.Auth -> String -> Task ()
postEmailConfirm { token } key =
    post
        { path = "/rest-auth/registration/verify-email/"
        , query = []
        , token = Just token
        , body = Just <| Encoders.emailConfirmationKey key
        , expect = expectNothing
        }



-- COMMENT


postComment : Types.Auth -> Types.Comment -> Task ()
postComment { token } comment =
    post
        { path = "/comments/"
        , query = []
        , token = Just token
        , body = Just <| Encoders.newComment comment
        , expect = expectNothing
        }



-- QUESTIONNAIRE


postQuestionnaire : Types.Auth -> Types.QuestionnaireForm -> Task ()
postQuestionnaire { token } questionnaire =
    post
        { path = "/questionnaires/"
        , query = []
        , token = Just token
        , body = Just <| Encoders.newQuestionnaire questionnaire
        , expect = expectNothing
        }



-- WORD SPAN


getWordSpan : Types.Auth -> Int -> Task Types.WordSpan
getWordSpan { token } id =
    get
        { path = "/word-spans/" ++ (toString id) ++ "/"
        , query = []
        , token = Just token
        , expect = Http.expectJson Decoders.wordSpan
        }



-- SENTENCE


getSentence : Types.Auth -> Int -> Task Types.Sentence
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
    -> Task (Types.Page Types.Sentence)
getSentences { token } maybePage query =
    get
        { path = "/sentences/"
        , query = query ++ (pageQuery maybePage)
        , token = Just token
        , expect = Http.expectJson (Decoders.page Decoders.sentence)
        }


postSentence : Types.Auth -> Types.NewSentence -> Task ()
postSentence { token } sentence =
    post
        { path = "/sentences/"
        , query = []
        , token = Just token
        , body = Just <| Encoders.newSentence sentence
        , expect = expectNothing
        }



-- TREE


getTree : Types.Auth -> Int -> Task Types.Tree
getTree { token } id =
    get
        { path = "/trees/" ++ (toString id) ++ "/"
        , query = []
        , token = Just token
        , expect = Http.expectJson Decoders.tree
        }


getServedTree :
    Types.Auth
    -> List ( String, String )
    -> Task (Maybe Types.Tree)
getServedTree { token } query =
    get
        { path = "/trees/serve_long_unserved_choice/"
        , query = query
        , token = Just token
        , expect = Http.expectJson (JD.list Decoders.tree |> JD.map List.head)
        }


getTrees :
    Types.Auth
    -> Maybe { pageSize : Int, page : Int }
    -> List ( String, String )
    -> Task (Types.Page Types.Tree)
getTrees { token } maybePage query =
    get
        { path = "/trees/"
        , query = query ++ (pageQuery maybePage)
        , token = Just token
        , expect = Http.expectJson (Decoders.page Decoders.tree)
        }
