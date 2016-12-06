module Strings exposing (..)

import Helpers
import Html
import Html.Attributes as Attributes
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


intPlease : String
intPlease =
    "Please enter a number"


genderPlease : String
genderPlease =
    "Please select a gender"


selectPlease : String
selectPlease =
    "Please select from the list"


jobTypePlease : String
jobTypePlease =
    "Please select a profession or main daily activity"


fiveCharactersPlease : String
fiveCharactersPlease =
    "Please type in at least 5 characters"


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


startTraining : List (Html.Html Msg)
startTraining =
    [ Html.text "Start the experiment "
    , Helpers.navA [] Router.Experiment "right now"
    , Html.text "!"
    ]


profileComplete : List (Html.Html Msg)
profileComplete =
    [ Html.text "Your profile is complete, you can keep going with "
    , Helpers.navA [] Router.Experiment "the experiment"
    ]


completeProfile : String
completeProfile =
    "Please complete your profile!"


questionnaireIntro : List String
questionnaireIntro =
    [ "We'd like to know a bit about you before you start the experiment. This will help us understand what influences your results as well as other participants' results."
    , "Your answers will be kept strictly private and will only be used for the purposes of the experiment."
    , "It takes about 2 minutes to fill the questionnaire. Thanks for participating, and welcome again to Gistr!"
    ]


questionnaireCheck : List (Html.Html msg)
questionnaireCheck =
    [ Html.strong [] [ Html.text "Make sure your answers are accurate!" ]
    , Html.text " Then you can submit them."
    ]


questionnaireInformed : String
questionnaireInformed =
    "Check this if you know what this experiment is about"


questionnaireInformedHow : List (Html.Html msg)
questionnaireInformedHow =
    [ Html.strong [] [ Html.text "How did you hear about the experiment?" ]
    , Html.text " You can use several sentences if necessary."
    ]


questionnaireInformedWhat : List (Html.Html msg)
questionnaireInformedWhat =
    [ Html.strong [] [ Html.text "What exactly do you know about the experiment?" ]
    , Html.text " Again, use several sentences if necessary."
    ]


questionnaireJobIntro : String
questionnaireJobIntro =
    "We'd like to know what type of job you work in, or what is your main daily activity."


questionnaireJobType : String
questionnaireJobType =
    "What is your general type of profession or main daily activity?"


questionnaireJobFreetext : List (Html.Html msg)
questionnaireJobFreetext =
    [ Html.strong [] [ Html.text "Please describe your profession or main daily activity." ]
    , Html.text " You can use several sentences if necessary."
    ]


questionnaireComment : List (Html.Html msg)
questionnaireComment =
    [ Html.text "Is there something wrong with this questionnaire, or a comment you would like to share? Please "
    , Html.a [ Attributes.href "mailto:sl@mehho.net" ] [ Html.text "contact us" ]
    , Html.text "!"
    ]


sentenceTooShort : Int -> String
sentenceTooShort minTokens =
    "Please type a longer sentence (at least " ++ toString minTokens ++ " words)"


homeSubtitle1 : List (Html.Html msg)
homeSubtitle1 =
    [ Html.text "A "
    , Html.strong [] [ Html.text "GWAP" ]
    , Html.text " on Memory and Interpretation"
    ]


homeSubtitle2 : List (Html.Html Msg)
homeSubtitle2 =
    [ Html.text "by the "
    , Html.a [ Attributes.href "https://cmb.hu-berlin.de/" ]
        [ Html.text "Centre Marc Bloch" ]
    , Html.text " in Berlin. "
    , Helpers.navA [] Router.About "Learn more"
    , Html.text "."
    ]


homeQuestions : List (Html.Html msg)
homeQuestions =
    [ Html.h3 [] [ Html.text "How good is your memory?" ]
    , Html.p [] [ Html.text "How well do you remember what you read?" ]
    , Html.p [] [ Html.text "With this experiment you'll learn how you unconsciously transform what you read. It lasts about 1 hour and it helps scientific research!" ]
    ]


resetProblem : String
resetProblem =
    "There was a problem. Did you use the last password-reset link you received?"


recoverPasswordNoEmailTitle : String
recoverPasswordNoEmailTitle =
    "Configure your emails"


recoverPasswordNoEmail : Html.Html Msg
recoverPasswordNoEmail =
    Html.div []
        [ Html.p []
            [ Html.text "We have no email address to send you a password reset link." ]
        , Html.p []
            [ Helpers.navA [] (Router.Profile Router.Emails) "Configure an email address"
            , Html.text " first!"
            ]
        ]


recoverPasswordSentTitle : String
recoverPasswordSentTitle =
    "Password reset by email"


recoverPasswordSent : String -> Html.Html msg
recoverPasswordSent email =
    Html.p []
        [ Html.text "We just sent an email to "
        , Html.strong [] [ Html.text email ]
        , Html.text " with instructions to reset your password"
        ]


verifyEmailSentTitle : String
verifyEmailSentTitle =
    "Verification email"


verifyEmailSent : String -> Html.Html msg
verifyEmailSent email =
    Html.p []
        [ Html.text "We just sent a verification email to "
        , Html.strong [] [ Html.text email ]
        , Html.text ", please follow the instructions in it"
        ]


emailConfirmedTitle : String
emailConfirmedTitle =
    "Email confirmed"


emailConfirmed : Html.Html msg
emailConfirmed =
    Html.text "Your email address was successfully confirmed!"


questionnaireCompletedTitle : String
questionnaireCompletedTitle =
    "Questionnaire completed"


questionnaireCompleted : Html.Html msg
questionnaireCompleted =
    Html.text "Thanks for filling the questionnaire!"


homeInstructionsGreeting : String
homeInstructionsGreeting =
    "Hi! Welcome to the Gistr Experiment :-)"


homeInstructionsProfileTests : String
homeInstructionsProfileTests =
    "There are a few tests and a questionnaire to fill in your profile page."


homeInstructionsProfileTestsWhenever : String
homeInstructionsProfileTestsWhenever =
    "Feel free to do them when you want to!"


homeInstructionsGetGoing : String
homeInstructionsGetGoing =
    "Get going on the experiment now! You'll get to know all about it afterwards."
