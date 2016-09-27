module Types
    exposing
        ( AuthStatus(..)
        , Auth
        , Credentials
        , Email
        , Feedback
        , Profile
        , RegisterCredentials
        , ResetCredentials
        , ResetTokens
        , Token
        , TreeCounts
        , User
        , Error(..)
        , customFeedback
        , emptyCredentials
        , emptyFeedback
        , emptyRegisterCredentials
        , emptyResetCredentials
        , globalFeedback
        , updateFeedback
        )

import Date
import Dict


-- API


type Error
    = ApiFeedback Feedback
    | Unrecoverable String



-- USER AND LOGIN


type alias User =
    { id : Int
    , username : String
    , isActive : Bool
    , isStaff : Bool
    , profile : Maybe Profile
    , emails : List Email
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


type AuthStatus
    = Anonymous
    | Authenticating
    | Authenticated Auth


type alias Auth =
    { token : Token, user : User }



-- PROFILE


type alias Profile =
    { id : Int
    , created : Date.Date
    , prolificId : Maybe String
    , userId : Int
    , userUsername : String
    , mothertongue : String
    , trained : Bool
    , reformulationsCount : Int
    , availableTreeCounts : TreeCounts
    }


type alias TreeCounts =
    { training : Int
    , experiment : Int
    }


type alias Email =
    { id : Int
    , user : Int
    , email : String
    , verified : Bool
    , primary : Bool
    , transacting : Bool
    }



{- Typical profile:

   ok    "available_trees_counts": {
   ok        "experiment": 0,
           "game": 0,
   ok        "training": 0
       },
   ok    "created": "2016-09-23T11:19:11.901445Z",
   ok    "id": 1,
       "introduced_exp_home": true,
       "introduced_exp_play": false,
       "introduced_play_home": false,
       "introduced_play_play": false,
   ok    "mothertongue": "english",
       "next_credit_in": 48,
   ok    "prolific_id": null,
       "questionnaire": null,
       "questionnaire_done": false,
   no    "questionnaire_url": null,
   ok    "reformulations_count": 0,
       "sentences": [],
       "sentences_count": 0,
       "suggestion_credit": 0,
   ok    "trained_reformulations": false,
       "trees": [],
       "trees_count": 0,
   no    "url": "http://127.0.0.1:8000/api/profiles/1/",
   ok    "user": 1,
   no    "user_url": "http://127.0.0.1:8000/api/users/1/",
   ok    "user_username": "sl",
       "word_span": null,
       "word_span_done": false,
   no    "word_span_url": null

-}
-- RESET


type alias ResetCredentials =
    { password1 : String
    , password2 : String
    }


emptyResetCredentials : ResetCredentials
emptyResetCredentials =
    ResetCredentials "" ""


type alias ResetTokens =
    { uid : String
    , token : String
    }



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
