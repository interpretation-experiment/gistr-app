module Types
    exposing
        ( User
        , Credentials
        , Token
        , Feedback
        , Auth(..)
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
