module Services.Account.Types exposing (..)

import HttpBuilder exposing (Error)


-- MESSAGES


type Msg
    = Login Credentials
    | TokenSucceed String
    | TokenFail Feedback
    | UserSucceed Token User
    | UserFail String
    | ClearFeedback
    | Logout
    | LogoutSucceed
    | LogoutFail String


type OutMsg
    = LoggedIn
    | LoggedOut



-- TRANSLATION


type alias TranslationDictionary t msg =
    { t | onLoggedIn : msg, onLoggedOut : msg }


type alias Translator parentMsg =
    OutMsg -> parentMsg



-- MODEL


type alias User =
    { id : Int
    , username : String
    , isActive : Bool
    , isStaff : Bool
    }


type alias Credentials =
    { username : String
    , password : String
    }


type alias Feedback =
    { username : Maybe String
    , password : Maybe String
    , global : Maybe String
    }


type alias Token =
    String


type AuthenticatingStatus
    = FetchingToken
    | FetchingUser
    | LoggingOut


type Model
    = Anonymous Feedback
    | Authenticating AuthenticatingStatus
    | Authenticated Token User
