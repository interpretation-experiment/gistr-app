module Types
    exposing
        ( Auth(..)
        , Credentials
        , Feedback
        , Token
        , User
        , emptyCredentials
        , emptyFeedback
        , globalFeedback
        )

import Dict


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


emptyCredentials : Credentials
emptyCredentials =
    Credentials "" ""


type alias Feedback =
    Dict.Dict String String


emptyFeedback : Feedback
emptyFeedback =
    Dict.empty


globalFeedback : String -> Feedback
globalFeedback value =
    Dict.singleton "global" value


type alias Token =
    String


type Auth
    = Anonymous
    | Authenticating
    | Authenticated Token User
