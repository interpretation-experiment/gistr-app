module Types
    exposing
        ( Auth(..)
        , Credentials
        , Feedback
        , RegisterCredentials
        , ResetCredentials
        , Token
        , User
        , customFeedback
        , emptyCredentials
        , emptyFeedback
        , emptyRegisterCredentials
        , emptyResetCredentials
        , globalFeedback
        , updateFeedback
        )

import Dict


-- USER AND LOGIN


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


type alias Token =
    String


type Auth
    = Anonymous
    | Authenticating
    | Authenticated Token User



-- RESET


type alias ResetCredentials =
    { password1 : String
    , password2 : String
    }


emptyResetCredentials : ResetCredentials
emptyResetCredentials =
    ResetCredentials "" ""



-- REGISTER


type alias RegisterCredentials =
    { username : String
    , email : String
    , password1 : String
    , password2 : String
    }


emptyRegisterCredentials : RegisterCredentials
emptyRegisterCredentials =
    RegisterCredentials "" "" "" ""



-- FORMS FEEDBACK
{- DO: think about changing Feedback into something like:
   type alias Feedback =
     { known : Dict.Dict String String
     , unknown : String
     }
   with corresponding helpers to handle it.
-}


type alias Feedback =
    Dict.Dict String String


emptyFeedback : Feedback
emptyFeedback =
    Dict.empty


globalFeedback : String -> Feedback
globalFeedback value =
    customFeedback "global" value


customFeedback : String -> String -> Feedback
customFeedback key =
    Dict.singleton key


updateFeedback : String -> Maybe String -> Feedback -> Feedback
updateFeedback key maybeValue feedback =
    case maybeValue of
        Nothing ->
            feedback

        Just value ->
            Dict.insert key value feedback
