module Api
    exposing
        ( Result
        , addEmail
        , changePassword
        , confirmEmail
        , deleteEmail
        , getAuth
        , getSentence
        , getSentences
        , getTree
        , getTrees
        , getWordSpan
        , login
        , logout
        , postQuestionnaire
        , postSentence
        , recover
        , register
        , reset
        , updateEmail
        , updateProfile
        , updateUser
        , verifyEmail
        )

import Api.Calls as Calls
import Task
import Types


type alias Result a =
    Result.Result Types.Error a



-- AUTH


getSelf : Types.Token -> Calls.Task Types.User
getSelf token =
    getSelfSettingProfile token Nothing


getSelfSettingProfile : Types.Token -> Maybe String -> Calls.Task Types.User
getSelfSettingProfile token maybeProlific =
    let
        finalize preUser =
            case preUser.profile of
                Just profile ->
                    Task.succeed { preUser | profile = profile }

                Nothing ->
                    Calls.postProfile { token = token, preUser = preUser } maybeProlific
                        |> Task.map (\profile -> { preUser | profile = profile })
    in
        Calls.getPreUser token |> Task.andThen finalize


getAuth : Types.Token -> Calls.Task Types.Auth
getAuth token =
    getAuthSettingProfile token Nothing


getAuthSettingProfile : Types.Token -> Maybe String -> Calls.Task Types.Auth
getAuthSettingProfile token maybeProlific =
    Task.map2 (Types.Auth token)
        (getSelfSettingProfile token maybeProlific)
        Calls.getMeta


login : Types.Credentials -> Calls.Task Types.Auth
login credentials =
    Calls.postLogin credentials
        |> Task.andThen getAuth


register : Types.RegisterCredentials -> Maybe String -> Calls.Task Types.Auth
register credentials maybeProlific =
    Calls.postRegister credentials
        |> Task.andThen (\token -> getAuthSettingProfile token maybeProlific)


logout : Types.Auth -> Calls.Task ()
logout =
    Calls.postLogout



-- PASSWORD


recover : String -> Calls.Task ()
recover =
    Calls.postRecovery


reset : Types.ResetTokens -> Types.ResetCredentials -> Calls.Task ()
reset =
    Calls.postReset


changePassword : Types.Auth -> Types.PasswordCredentials -> Calls.Task Types.Auth
changePassword auth credentials =
    let
        loginCredentials =
            { username = auth.user.username, password = credentials.password1 }
    in
        Calls.postPassword auth credentials
            |> Task.andThen (always <| Calls.postLogout auth)
            |> Task.andThen (always <| login loginCredentials)



-- USER


updateUser : Types.Auth -> Types.User -> Calls.Task Types.User
updateUser =
    Calls.putUser



-- PROFILE


updateProfile : Types.Auth -> Types.Profile -> Calls.Task Types.Profile
updateProfile =
    Calls.putProfile



-- EMAIL


addEmail : Types.Auth -> String -> Calls.Task Types.User
addEmail auth email =
    Calls.postEmail auth email
        |> Task.andThen (always <| getSelf auth.token)


updateEmail : Types.Auth -> Types.Email -> Calls.Task Types.User
updateEmail auth email =
    Calls.putEmail auth email
        |> Task.andThen (always <| getSelf auth.token)


deleteEmail : Types.Auth -> Types.Email -> Calls.Task Types.User
deleteEmail auth email =
    Calls.deleteEmail auth email
        |> Task.andThen (always <| getSelf auth.token)


verifyEmail : Types.Auth -> Types.Email -> Calls.Task ()
verifyEmail =
    Calls.postEmailVerify


confirmEmail : Types.Auth -> String -> Calls.Task Types.User
confirmEmail auth key =
    Calls.postEmailConfirm auth key
        |> Task.andThen (always <| getSelf auth.token)



-- QUESTIONNAIRE


postQuestionnaire : Types.Auth -> Types.QuestionnaireForm -> Calls.Task Types.Profile
postQuestionnaire auth questionnaire =
    Calls.postQuestionnaire auth questionnaire
        |> Task.andThen (always <| Task.map .profile <| getSelf auth.token)



-- WORD SPAN


getWordSpan : Types.Auth -> Int -> Calls.Task Types.WordSpan
getWordSpan =
    Calls.getWordSpan



-- SENTENCE


getSentence : Types.Auth -> Int -> Calls.Task Types.Sentence
getSentence =
    Calls.getSentence


getSentences :
    Types.Auth
    -> Maybe { pageSize : Int, page : Int }
    -> List ( String, String )
    -> Calls.Task (Types.Page Types.Sentence)
getSentences =
    Calls.getSentences


postSentence : Types.Auth -> Types.NewSentence -> Calls.Task Types.Profile
postSentence auth sentence =
    Calls.postSentence auth sentence
        |> Task.andThen (always <| Task.map .profile <| getSelf auth.token)



-- TREE


getTree : Types.Auth -> Int -> Calls.Task Types.Tree
getTree =
    Calls.getTree


getTrees :
    Types.Auth
    -> Maybe { pageSize : Int, page : Int }
    -> List ( String, String )
    -> Calls.Task (Types.Page Types.Tree)
getTrees =
    Calls.getTrees
