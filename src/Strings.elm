module Strings exposing (..)

import Helpers
import Html
import Msg exposing (Msg)
import Router


invalidProlific : String
invalidProlific =
    "This is not a valid Prolific Academic ID"


passwordTooShort : String
passwordTooShort =
    "Password must be at least 6 characters"


passwordsDontMatch : String
passwordsDontMatch =
    "The two password don't match"


passwordSaved : String
passwordSaved =
    "Password saved!"


usernameSaved : String
usernameSaved =
    "Username saved!"


emailAdded : String
emailAdded =
    "Email address added!"


fillQuestionnaire : String
fillQuestionnaire =
    "Fill in the general questionnaire below"


testWordSpan : String
testWordSpan =
    "Test your word span below"


startExperiment : List (Html.Html Msg)
startExperiment =
    [ Html.text "Start the experiment "
      -- TODO: set to Router.Exp
    , Helpers.navA Router.Home "right now"
    ]


profileComplete : List (Html.Html Msg)
profileComplete =
    [ Html.text "Your profile is complete, you can keep going with "
      -- TODO: set to Router.Exp
    , Helpers.navA Router.Home "the experiment"
    ]


completeProfile : String
completeProfile =
    "Please complete your profile!"
