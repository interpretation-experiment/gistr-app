module Types
    exposing
        ( Auth
        , AuthStatus(..)
        , Choice
        , Credentials
        , Edge
        , Email
        , Error(..)
        , Meta
        , NewSentence
        , NewWordSpan
        , Notification(..)
        , Page
        , PasswordCredentials
        , PreUser
        , Profile
        , QuestionnaireForm
        , RegisterCredentials
        , ResetCredentials
        , ResetTokens
        , Sentence
        , Token
        , Tree
        , TreeCounts
        , User
        , WordSpan
        , emptyCredentials
        , emptyPasswordCredentials
        , emptyQuestionnaireForm
        , emptyRegisterCredentials
        , emptyResetCredentials
        )

import Date
import Http
import Time


-- API


type Error
    = HttpError Http.Error
    | Unrecoverable String


type alias Choice =
    { name : String, label : String }


type alias Meta =
    { -- TREE SHAPING
      targetBranchDepth : Int
    , targetBranchCount : Int
    , branchProbability : Float
    , -- READ-WRITE PARAMETERS
      readFactor : Int
    , writeFactor : Int
    , minTokens : Int
    , pausePeriod : Int
    , -- FORM PARAMETERS
      genderChoices : List Choice
    , jobTypeChoices : List Choice
    , bucketChoices : List Choice
    , -- EXPERIMENT COSTS
      experimentWork : Int
    , trainingWork : Int
    , treeCost : Int
    , baseCredit : Int
    , -- LANGUAGES
      defaultLanguge : String
    , supportedLanguages : List Choice
    , otherLanguage : String
    }


type alias Page a =
    { totalItems : Int
    , items : List a
    }



-- USER AND LOGIN


type alias PreUser =
    { -- IMMUTABLE
      id : Int
    , -- PROPER
      username : String
    , isActive : Bool
    , isStaff : Bool
    , -- RELATIONSHIPS
      profile : Maybe Profile
    , emails : List Email
    }


type alias User =
    { -- IMMUTABLE
      id : Int
    , -- PROPER
      username : String
    , isActive : Bool
    , isStaff : Bool
    , -- RELATIONSHIPS
      profile : Profile
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
    { token : Token, user : User, meta : Meta }



-- PROFILE
{- Example profile:

   ✓    "available_trees_counts": {
   ✓        "experiment": 0,
            "game": 0,
   ✓        "training": 0
       },
   ✓    "created": "2016-09-23T11:19:11.901445Z",
   ✓    "id": 1,
   ✓    "introduced_exp_home": true,
   ✓    "introduced_exp_play": false,
        "introduced_play_home": false,
        "introduced_play_play": false,
   ✓    "mothertongue": "english",
        "next_credit_in": 48,
   ✓    "prolific_id": null,
   ✓    "questionnaire": null,
   ✗    "questionnaire_done": false,
   ✗    "questionnaire_url": null,
   ✓    "reformulations_count": 0,
   ✓    "sentences": [],
   ✗    "sentences_count": 0,
        "suggestion_credit": 0,
   ✓    "trained_reformulations": false,
   ✓    "trees": [],
   ✗    "trees_count": 0,
   ✗    "url": "http://127.0.0.1:8000/api/profiles/1/",
   ✓    "user": 1,
   ✗    "user_url": "http://127.0.0.1:8000/api/users/1/",
   ✓    "user_username": "sl",
   ✓    "word_span": null,
   ✗    "word_span_done": false,
   ✗    "word_span_url": null

-}


type alias Profile =
    { -- IMMUTABLE
      id : Int
    , created : Date.Date
    , -- PROPER
      prolificId : Maybe String
    , mothertongue : String
    , trained : Bool
    , introducedExpHome : Bool
    , introducedExpPlay : Bool
    , -- RELATIONSHIPS
      userId : Int
    , questionnaireId : Maybe Int
    , wordSpanId : Maybe Int
    , sentencesIds : List Int
    , treesIds : List Int
    , -- COMPUTED
      userUsername : String
    , reformulationsCount : Int
    , availableTreeCounts : TreeCounts
    }


type alias TreeCounts =
    { training : Int
    , experiment : Int
    }


type alias Email =
    { -- IMMUTABLE
      id : Int
    , -- PROPER
      email : String
    , verified : Bool
    , primary : Bool
    , -- RELATIONSHIPS
      userId : Int
    , -- LOCAL
      transacting : Bool
    }


type alias WordSpan =
    { -- IMMUTABLE
      id : Int
    , created : Date.Date
    , -- PROPER
      span : Int
    , score : Int
    , -- RELATIONSHIPS
      profileId : Int
    }


type alias NewWordSpan =
    { span : Int
    , score : Int
    }


type alias QuestionnaireForm =
    { -- PROPER
      age : String
    , gender : String
    , informed : Bool
    , informedHow : String
    , informedWhat : String
    , jobType : String
    , jobFreetext : String
    }


emptyQuestionnaireForm : QuestionnaireForm
emptyQuestionnaireForm =
    { age = ""
    , gender = ""
    , informed = False
    , informedHow = ""
    , informedWhat = ""
    , jobType = ""
    , jobFreetext = ""
    }



-- SENTENCE


type alias Sentence =
    { -- IMMUTABLE
      id : Int
    , created : Date.Date
    , -- PROPER
      text : String
    , language : String
    , bucket : String
    , readTimeProportion : Float
    , readTimeAllotted : Time.Time
    , writeTimeProportion : Float
    , writeTimeAllotted : Time.Time
    , -- RELATIONSHIPS
      treeId : Int
    , profileId : Int
    , parentId : Maybe Int
    , childrenIds : List Int
    , -- COMPUTED
      profileUsername : String
    }


type alias NewSentence =
    { -- PROPER
      text : String
    , language : String
    , bucket : String
    , readTimeProportion : Float
    , readTimeAllotted : Time.Time
    , writeTimeProportion : Float
    , writeTimeAllotted : Time.Time
    , -- RELATIONSHIPS
      parentId : Maybe Int
    }



-- TREE


type alias Tree =
    { -- IMMUTABLE
      id : Int
    , -- RELATIONSHIPS
      root : Sentence
    , sentencesIds : List Int
    , profilesIds : List Int
    , networkEdges : List (Edge Int)
    , -- COMPUTED
      branchesCount : Int
    , shortestBranchDepth : Int
    }


type alias Edge a =
    { source : a
    , target : a
    }



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



-- NOTIFICATION


type Notification
    = Info
    | Warning
    | Success
