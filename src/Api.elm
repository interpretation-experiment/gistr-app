module Api
    exposing
        ( addEmail
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
import Api.Calls exposing (ApiTask)
import Types


-- AUTH


getSelf : Types.Token -> ApiTask Types.User
getSelf token =
    getSelfSettingProfile token Nothing


getSelfSettingProfile : Types.Token -> Maybe String -> ApiTask Types.User
getSelfSettingProfile token maybeProlific =
    let
        finalize preUser =
            case preUser.profile of
                Just profile ->
                    Calls.succeed { preUser | profile = profile }

                Nothing ->
                    Calls.postProfile { token = token, preUser = preUser } maybeProlific
                        |> Calls.map (\profile -> { preUser | profile = profile })
    in
        Calls.getPreUser token |> Calls.andThen finalize


getAuth : Types.Token -> ApiTask Types.Auth
getAuth token =
    getAuthSettingProfile token Nothing


getAuthSettingProfile : Types.Token -> Maybe String -> ApiTask Types.Auth
getAuthSettingProfile token maybeProlific =
    Calls.map2 (Types.Auth token)
        (getSelfSettingProfile token maybeProlific)
        Calls.getMeta


login : Types.Credentials -> ApiTask Types.Auth
login credentials =
    Calls.postLogin credentials
        |> Calls.andThen getAuth


register : Types.RegisterCredentials -> Maybe String -> ApiTask Types.Auth
register credentials maybeProlific =
    Calls.postRegister credentials
        |> Calls.andThen (\token -> getAuthSettingProfile token maybeProlific)


logout : Types.Auth -> ApiTask ()
logout =
    Calls.postLogout



-- PASSWORD


recover : String -> ApiTask ()
recover =
    Calls.postRecovery


reset : Types.ResetTokens -> Types.ResetCredentials -> ApiTask ()
reset =
    Calls.postReset


changePassword : Types.Auth -> Types.PasswordCredentials -> ApiTask Types.Auth
changePassword auth credentials =
    let
        loginCredentials =
            { username = auth.user.username, password = credentials.password1 }
    in
        Calls.postPassword auth credentials
            |> Calls.andThen (always <| Calls.postLogout auth)
            |> Calls.andThen (always <| login loginCredentials)



-- USER


updateUser : Types.Auth -> Types.User -> ApiTask Types.User
updateUser =
    Calls.putUser



-- PROFILE


updateProfile : Types.Auth -> Types.Profile -> ApiTask Types.Profile
updateProfile =
    Calls.putProfile



-- EMAIL


addEmail : Types.Auth -> String -> ApiTask Types.User
addEmail auth email =
    Calls.postEmail auth email
        |> Calls.andThen (always <| getSelf auth.token)


updateEmail : Types.Auth -> Types.Email -> ApiTask Types.User
updateEmail auth email =
    Calls.putEmail auth email
        |> Calls.andThen (always <| getSelf auth.token)


deleteEmail : Types.Auth -> Types.Email -> ApiTask Types.User
deleteEmail auth email =
    Calls.deleteEmail auth email
        |> Calls.andThen (always <| getSelf auth.token)


verifyEmail : Types.Auth -> Types.Email -> ApiTask ()
verifyEmail =
    Calls.postEmailVerify


confirmEmail : Types.Auth -> String -> ApiTask Types.User
confirmEmail auth key =
    Calls.postEmailConfirm auth key
        |> Calls.andThen (always <| getSelf auth.token)



-- QUESTIONNAIRE


postQuestionnaire : Types.Auth -> Types.QuestionnaireForm -> ApiTask Types.Profile
postQuestionnaire auth questionnaire =
    Calls.postQuestionnaire auth questionnaire
        |> Calls.andThen (always <| Calls.map .profile <| getSelf auth.token)



-- WORD SPAN


getWordSpan : Types.Auth -> Int -> ApiTask Types.WordSpan
getWordSpan =
    Calls.getWordSpan



-- SENTENCE


getSentence : Types.Auth -> Int -> ApiTask Types.Sentence
getSentence =
    Calls.getSentence


getSentences :
    Types.Auth
    -> Maybe { pageSize : Int, page : Int }
    -> List ( String, String )
    -> ApiTask (Types.Page Types.Sentence)
getSentences =
    Calls.getSentences


postSentence : Types.Auth -> Types.NewSentence -> ApiTask Types.Profile
postSentence auth sentence =
    Calls.postSentence auth sentence
        |> Calls.andThen (always <| Calls.map .profile <| getSelf auth.token)



-- TREE


getTree : Types.Auth -> Int -> ApiTask Types.Tree
getTree =
    Calls.getTree


getTrees :
    Types.Auth
    -> Maybe { pageSize : Int, page : Int }
    -> List ( String, String )
    -> ApiTask (Types.Page Types.Tree)
getTrees =
    Calls.getTrees
