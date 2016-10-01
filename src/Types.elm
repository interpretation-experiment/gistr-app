module Types
    exposing
        ( Auth
        , AuthStatus(..)
        , Credentials
        , Email
        , Error(..)
        , PasswordCredentials
        , PreUser
        , Profile
        , RegisterCredentials
        , ResetCredentials
        , ResetTokens
        , Token
        , TreeCounts
        , User
        , emptyCredentials
        , emptyPasswordCredentials
        , emptyRegisterCredentials
        , emptyResetCredentials
        )

import Date
import Feedback


-- API


type Error
    = ApiFeedback Feedback.Feedback
    | Unrecoverable String



-- USER AND LOGIN


type alias PreUser =
    { id : Int
    , username : String
    , isActive : Bool
    , isStaff : Bool
    , profile : Maybe Profile
    , emails : List Email
    }


type alias User =
    { id : Int
    , username : String
    , isActive : Bool
    , isStaff : Bool
    , profile : Profile
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
    , questionnaireId : Maybe Int
    , wordSpanId : Maybe Int
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
   ok    "questionnaire": null,
   no    "questionnaire_done": false,
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
   ok    "word_span": null,
   no    "word_span_done": false,
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



-- PASSWORD


type alias PasswordCredentials =
    { oldPassword : String
    , password1 : String
    , password2 : String
    }


emptyPasswordCredentials : PasswordCredentials
emptyPasswordCredentials =
    PasswordCredentials "" "" ""
