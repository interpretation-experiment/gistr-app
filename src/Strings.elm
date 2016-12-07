module Strings exposing (..)

import Config
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
    [ Html.text "Your profile is complete, you can start the experiment "
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


expDone : String
expDone =
    "You finished the experiment! Thanks for participating."


prolificCompletion : String
prolificCompletion =
    "Now, click the following button to tell Prolific Academic you finished the study, so you can get paid."


prolificCompletionButton : String
prolificCompletionButton =
    "Complete with Prolific Academic"


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
    "Please type a little more (at least " ++ toString minTokens ++ " words altogether)"


homeSubtitle1 : List (Html.Html msg)
homeSubtitle1 =
    [ Html.text "A "
    , Html.strong [ Helpers.tooltip "Game With a Purpose" ] [ Html.text "GWAP" ]
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


homeGetPaid : List (Html.Html msg)
homeGetPaid =
    [ Html.text " — "
    , Html.a
        [ Attributes.href Config.prolificStudyUrl
        , Attributes.title "Gistr on Prolific Academic"
        ]
        [ Html.text "get paid for it" ]
    , Html.text " if you want"
    ]


homeIfStarted : String
homeIfStarted =
    " — if you've already started"


homeReadAbout : List (Html.Html Msg)
homeReadAbout =
    [ Html.text "If you're interested, you can find out more about the experiment in the "
    , Helpers.navA [] Router.About "About"
    , Html.text " page."
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


aboutAboutTitle : String
aboutAboutTitle =
    "The game and experiment"


aboutAboutTeaserHowGood : String
aboutAboutTeaserHowGood =
    "How good is your memory? How well do you remember what you read?"


aboutAboutTeaserShows : String
aboutAboutTeaserShows =
    "This experiment shows you how you unconsciously transform what you read: you'll see detailed statistics on how you transform what you read, and see how you compare to the other participants. It lasts about 1 hour and it helps scientific research!"


aboutAboutTeaserMore : List (Html.Html Msg)
aboutAboutTeaserMore =
    [ Html.text "Want to read more about this? Please "
    , Helpers.navA [] Router.Experiment "pass the experiment"
    , Html.text " first!"
    ]


aboutAboutFullSay : List (Html.Html Msg)
aboutAboutFullSay =
    [ Html.strong [] [ Html.text "Say something:" ]
    , Html.text " it means one thing to your partner, another thing to your closest friend, something else to your parents, and something different again to the stranger you meet in the street. When a politician says something on television, members of his party and the opposition hear different meanings in what was said."
    ]


aboutAboutFullWhat : String
aboutAboutFullWhat =
    "What are the processes involved in these interpretations? How do we make sense of the world around us?"


aboutAboutFullGistr : String
aboutAboutFullGistr =
    "Gistr is both a game and an experiment on how we interpret and make sense in certain contexts, and what consequences this has at large scale. The goal is to collect high quality data on repeated interpretations of content, allowing participants to experiment with texts and contexts of their own also."


aboutAboutFullOpen : List (Html.Html Msg)
aboutAboutFullOpen =
    [ Html.text "This experiment is entirely Free Software, and the development is an "
    , Html.a
        [ Attributes.href "https://github.com/interpretation-experiment"
        , Attributes.title "Gistr Repositories"
        ]
        [ Html.text "open process" ]
    , Html.text ". Find out more on "
    , Html.a
        [ Attributes.href "https://github.com/interpretation-experiment/gistr-app/wiki"
        , Attributes.title "Gistr Wiki"
        ]
        [ Html.text "the wiki" ]
    , Html.text "!"
    ]


aboutPrivacyTitle : String
aboutPrivacyTitle =
    "Privacy"


aboutPrivacyCollects : String
aboutPrivacyCollects =
    "The experiment collects mostly public data: texts and their reformulations, along with the time used to write them."


aboutPrivacyDont : String
aboutPrivacyDont =
    "We don't ask for your name or any other personally identifying information. Your profile, however, contains sensitive data:"


aboutPrivacyQuestionnaire : String
aboutPrivacyQuestionnaire =
    "A questionnaire you fill during the experiment,"


aboutPrivacyWordSpan : String
aboutPrivacyWordSpan =
    "A word span test you may pass later on,"


aboutPrivacyEmail : String
aboutPrivacyEmail =
    "Your email address if you choose to enter it (that's optional)."


aboutPrivacyPrivate : String
aboutPrivacyPrivate =
    "This information is carefully kept private: no one but our team will ever have access to it, and as with all the data collected here it is only used for the purposes of the experiment."


aboutAuthorsTitle : String
aboutAuthorsTitle =
    "The authors"


aboutAuthorsCreated : List (Html.Html Msg)
aboutAuthorsCreated =
    [ Html.text "Created and developed by "
    , Html.a
        [ Attributes.href "https://slvh.fr/"
        , Attributes.title "Sébastien Lerique's Homepage"
        ]
        [ Html.text "Sébastien Lerique" ]
    , Html.text " as part of his PhD, advised by and thoroughly discussed with "
    , Html.a
        [ Attributes.href "http://camille.roth.free.fr/index.php"
        , Attributes.title "Camille Roth's Homepage"
        ]
        [ Html.text "Camille Roth" ]
    , Html.text ". Both are at the "
    , Html.a
        [ Attributes.href "https://cmb.hu-berlin.de/"
        , Attributes.title "Centre Marc Bloch Webpage"
        ]
        [ Html.text "Centre Marc Bloch" ]
    , Html.text " in Berlin, and the "
    , Html.a
        [ Attributes.href "http://cams.ehess.fr/"
        , Attributes.title "CAMS Webpage"
        ]
        [ Html.text "CAMS" ]
    , Html.text " in Paris."
    ]


expReadMemorize : String
expReadMemorize =
    "Read and memorize the following"


expTask : String
expTask =
    "Pause a few seconds"


expWrite : String
expWrite =
    "Write down the text as you remember it"


expTimeoutTitle : String
expTimeoutTitle =
    "Time's up!"


expTimeoutExplanation : String
expTimeoutExplanation =
    "You need to be quicker next time, check the progress circle!"
