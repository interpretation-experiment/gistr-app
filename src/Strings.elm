module Strings exposing (..)

import Comment.Msg as CommentMsg
import Config
import ElmEscapeHtml
import Helpers
import Html
import Html.Attributes as Attributes
import Msg exposing (Msg)
import Router
import Styles exposing (class, classList, id)


invalidProlific : String
invalidProlific =
    "This is not a valid Prolific Academic ID"


passwordTooShort : String
passwordTooShort =
    "Password must be at least 6 characters"


passwordsDontMatch : String
passwordsDontMatch =
    "The two password don't match"


registerProlificYourIdIs : String
registerProlificYourIdIs =
    "Your ID is"


registerProlificSignUp : List (Html.Html msg)
registerProlificSignUp =
    [ Html.text "Now, "
    , Html.strong [] [ Html.text "sign up to start the experiment" ]
    ]


registerProlificGoBack : List (Html.Html Msg)
registerProlificGoBack =
    [ Html.text "(Made a mistake? "
    , Helpers.navA [] Router.Prolific "Go back"
    , Html.text ")"
    ]


registerProlificQuestion : List (Html.Html Msg)
registerProlificQuestion =
    [ Html.text "Prolific Academic participant? "
    , Helpers.navA [] Router.Prolific "Please enter your ID"
    , Html.text " first"
    ]


registerAlreadyAccount : List (Html.Html Msg)
registerAlreadyAccount =
    [ Html.text "Already have an account? "
    , Helpers.navA [] (Router.Login Nothing) "Sign in here"
    ]


registerEmailVerify : String
registerEmailVerify =
    "Once you've registered, we'll send you a verification email to make sure this works."


passwordPlaceholder1 : String
passwordPlaceholder1 =
    "Elaborate password"


passwordPlaceholder2 : String
passwordPlaceholder2 =
    "Same old, same old"


oldPasswordPlaceholder : String
oldPasswordPlaceholder =
    "Your old password"


emailPlaceholder : String
emailPlaceholder =
    "e.g. joey@example.com"


optionalEmailPlaceholder : String
optionalEmailPlaceholder =
    "e.g. joey@example.com (optional)"


commentPlaceholder : String
commentPlaceholder =
    "Please detail exactly what your concern is"


commentIntro : String
commentIntro =
    "Want to submit feedback or a comment? Thanks, we're thrilled! Please fill in the following fields"


usernamePlaceholder : String
usernamePlaceholder =
    "e.g. joey"


prolificIdPlaceholder : String
prolificIdPlaceholder =
    "e.g. 5381d3c8717b341db325eec3"


intPlease : String
intPlease =
    "Please enter a number"


genderPlease : String
genderPlease =
    "Please select a gender"


selectPlease : String
selectPlease =
    "Please select from the list"


educationLevelPlease : String
educationLevelPlease =
    "Please select an education level"


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
    [ Html.text "Your profile is complete — "
    , Helpers.navButton [ class [ Styles.Btn, Styles.BtnPrimary ] ]
        Router.Experiment
        "Start the Experiment"
    ]


profileComplete : List (Html.Html Msg)
profileComplete =
    [ Html.text "Your profile is complete — "
    , Helpers.navButton [ class [ Styles.Btn, Styles.BtnPrimary ] ]
        Router.Experiment
        "Continue with the Experiment"
    ]


completeProfile : String
completeProfile =
    "Please complete your profile!"


expDone : String
expDone =
    "You finished the experiment! Thanks for participating."


expInstructionsWelcome : String
expInstructionsWelcome =
    "Welcome to the Gistr Experiment!"


expInstructionsReadText : String
expInstructionsReadText =
    ElmEscapeHtml.unescape "{{strings-expInstructionsReadText}}"


expInstructionsPause : String
expInstructionsPause =
    "Then there's a pause"


expInstructionsRewrite : String
expInstructionsRewrite =
    "And you must rewrite what you remember as best you can"


expInstructionsRewriteProlificBonus : String
expInstructionsRewriteProlificBonus =
    "Each sentence you accurately rewrite gives you bonus Prolific Academic payment. Up to +25% in total!"


expInstructionsSentOther : String
expInstructionsSentOther =
    "What you write is then sent directly to the next participant in the experiment"


expInstructionsTakeTime : List (Html.Html msg)
expInstructionsTakeTime =
    [ Html.text "So "
    , Html.strong [] [ Html.text "take your time" ]
    , Html.text " to write as properly as possible."
    ]


expInstructionsMakeSense : List (Html.Html msg)
expInstructionsMakeSense =
    [ Html.text "Make sure you "
    , Html.strong [] [ Html.text "send something that makes sense" ]
    , Html.text " for the next participant, even if you can't remember the original or if it was a bit messy (correct it!)"
    ]


expInstructionsLoop : String
expInstructionsLoop =
    "The whole process loops once you're done"


expInstructionsBreak : String
expInstructionsBreak =
    "And there's a break after each sentence you enter"


expInstructionsDontInterrupt : List (Html.Html msg)
expInstructionsDontInterrupt =
    [ Html.text "Make sure you're "
    , Html.strong [] [ Html.text "not interrupted" ]
    , Html.text " while reading or writing a sentence! You can always talk to other people during one of the breaks."
    ]


expInstructionsTraining : List (Html.Html msg)
expInstructionsTraining =
    [ Html.text "Right now you're in "
    , Html.strong [] [ Html.text "training" ]
    , Html.text ": nothing you do is recorded"
    ]


expInstructionsRealStart : Int -> String
expInstructionsRealStart num =
    "The real experiment starts after " ++ (toString num) ++ " trials"


expNoCopyPasteTitle : String
expNoCopyPasteTitle =
    "No copy-pasting"


expNoCopyPaste : Html.Html msg
expNoCopyPaste =
    Html.text "Please don't copy-paste the text, it won't work!"


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


questionnaireEducationJobIntro : String
questionnaireEducationJobIntro =
    "We'd like to know how much you've studied, as well as what type of job you work in, or what your main daily activity is."


questionnaireEducationLevel : String
questionnaireEducationLevel =
    "What is the highest level of education you attained?"


questionnaireEducationFreetext : List (Html.Html msg)
questionnaireEducationFreetext =
    [ Html.strong [] [ Html.text "Please describe, in your own words, the highest level of education you attained." ]
    , Html.text " You can use several sentences if necessary."
    ]


questionnaireJobType : String
questionnaireJobType =
    "What is your general type of profession or main daily activity?"


questionnaireJobFreetext : List (Html.Html msg)
questionnaireJobFreetext =
    [ Html.strong [] [ Html.text "Please describe your profession or main daily activity." ]
    , Html.text " You can use several sentences if necessary."
    ]


questionnaireComment : List (Html.Html Msg)
questionnaireComment =
    [ Html.text "Is there something wrong with this questionnaire, or a comment you would like to share? Please "
    , Helpers.evA [] "#" (Msg.CommentMsg CommentMsg.Show) "tell us about it"
    , Html.text "!"
    ]


sentenceTooShort : Int -> String
sentenceTooShort minTokens =
    "Please type a little more (at least " ++ toString minTokens ++ " words altogether)"


homeSubtitle : List (Html.Html Msg)
homeSubtitle =
    [ Html.text "A "
    , Html.strong [ Helpers.tooltip "Game With a Purpose" ] [ Html.text "GWAP" ]
    , Html.text " on Memory and Interpretation"
    , Html.br [] []
    , Html.text "by the "
    , Html.a [ Attributes.href "https://cmb.hu-berlin.de/" ]
        [ Html.text "Centre Marc Bloch" ]
    , Html.text "'s "
    , Html.a
        [ Attributes.href "http://cmb.huma-num.fr/"
        , Attributes.title "CMB's Computational Social Sciences Team"
        ]
        [ Html.text "CSS Team" ]
    , Html.text " in Berlin. "
    , Helpers.navA [] Router.About "Learn more"
    , Html.text "."
    ]


homeQuestions : List (Html.Html msg)
homeQuestions =
    [ Html.h3 [] [ Html.text "How good is your memory?" ]
    , Html.p [] [ Html.text "How well do you remember what you read?" ]
    , Html.p []
        [ Html.text <|
            "With this experiment you'll learn how you unconsciously transform what you read. It lasts about "
                ++ Config.expDuration
                ++ " and it helps scientific research!"
        ]
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


expDoneReadAbout : List (Html.Html Msg)
expDoneReadAbout =
    [ Html.p []
        [ Html.text "If you're interested, you can find out more about the experiment in the "
        , Helpers.navA [] Router.About "About"
        , Html.text " page."
        ]
    , Html.p []
        [ Html.text "If you have any comments or feedback, please "
        , Helpers.evA [] "#" (Msg.CommentMsg CommentMsg.Show) "tell us about it"
        , Html.text "!"
        ]
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
    "This experiment shows you how you unconsciously transform what you read: you'll see detailed statistics on how you transform what you read, and see how you compare to the other participants. It lasts about " ++ Config.expDuration ++ " and it helps scientific research!"


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
    , Html.text "'s "
    , Html.a
        [ Attributes.href "http://cmb.huma-num.fr/"
        , Attributes.title "CMB's Computational Social Sciences Webpage"
        ]
        [ Html.text "Computational Social Sciences Team" ]
    , Html.text " in Berlin, and the "
    , Html.a
        [ Attributes.href "http://cams.ehess.fr/"
        , Attributes.title "CAMS Webpage"
        ]
        [ Html.text "CAMS" ]
    , Html.text " in Paris."
    ]


aboutToolsTitle : String
aboutToolsTitle =
    "Tools"


aboutToolsGeneric : List (Html.Html msg)
aboutToolsGeneric =
    [ Html.text "Gistr is developed using "
    , Html.a
        [ Attributes.href "http://elm-lang.org/"
        , Attributes.title "Elm Website"
        ]
        [ Html.text "Elm" ]
    , Html.text " for the frontend, and the "
    , Html.a
        [ Attributes.href "http://www.django-rest-framework.org/"
        , Attributes.title "Django Rest Framework Website"
        ]
        [ Html.text "Django Rest Framework" ]
    , Html.text " for the backend."
    ]


aboutToolsCompanies : String
aboutToolsCompanies =
    "The following companies have also donated access to their products, used throughout the development."


expReadMemorize : String
expReadMemorize =
    "Read and memorize the following"


expTask : String
expTask =
    "Wait a few seconds"


expWrite : String
expWrite =
    "Write down the text as you remember it"


reportProblem : String
reportProblem =
    "Report a problem"


expSpellingError : String -> List (Html.Html Msg)
expSpellingError mispellingMsg =
    let
        mispellings =
            mispellingMsg
                |> String.split ", "
                |> List.map (\e -> Html.code [] [ Html.text e ])
                |> List.intersperse (Html.text ", ")
    in
        [ Html.h3 [] [ Html.text "Check your spelling" ]
        , Html.p [] <|
            mispellings
                ++ [ Html.text <|
                        Helpers.plural " seems" " seem" (List.length mispellings)
                            ++ " to be mispelled and could confuse the next participant reading your input."
                   ]
        , Html.p []
            [ Html.text "Make sure your whole sentence is well spelled! Use your browser's built-in spell-checker for help."
            ]
        ]


expPunctuationRepeatedError : String -> List (Html.Html Msg)
expPunctuationRepeatedError repeats =
    [ Html.h3 [] [ Html.text "Avoid repeated punctuation" ]
    , Html.p []
        [ Html.text "Using repeated punctuation ("
        , Html.code [] [ Html.text <| String.trim repeats ]
        , Html.text ") will confuse the next participant reading your input."
        ]
    , Html.p []
        [ Html.text "Make sure to "
        , Html.strong [] [ Html.text "write a complete sentence that makes sense" ]
        , Html.text " based on what you remember. (If you don't remember much, that's normal.)"
        ]
    , Html.p []
        [ Html.text "Don't send anything like "
        , Html.code [] [ Html.text "..." ]
        , Html.text " or  "
        , Html.code [] [ Html.text "I don't know" ]
        , Html.text " to the next participant!"
        ]
    ]


expPunctuationExcludedError : String -> List (Html.Html Msg)
expPunctuationExcludedError excluded =
    [ Html.h3 [] [ Html.text "Avoid special punctuation" ]
    , Html.p []
        [ Html.text "Using "
        , Html.code [] [ Html.text <| String.trim excluded ]
        , Html.text " in your sentence is misleading for the next participant reading your input."
        ]
    , Html.p []
        ([ Html.text "None of " ]
            ++ excludedPunctuation
            ++ [ Html.text " are accepted in sentences, so make sure you don't use any of them!" ]
        )
    ]


excludedPunctuation : List (Html.Html msg)
excludedPunctuation =
    "[]{}<>\\|/+=_*&^%$#@~"
        |> String.toList
        |> List.map (\p -> Html.code [] [ Html.text <| String.fromChar p ])
        |> List.intersperse (Html.text ", ")


expTimeoutTitle : String
expTimeoutTitle =
    "Time's up!"


expTimeoutExplanation : String
expTimeoutExplanation =
    "You need to be quicker next time, check the progress circle!"


expTrainingFinishedTitle : String
expTrainingFinishedTitle =
    "You finished training!"


expTrainingFinishedCompleteProfile : String
expTrainingFinishedCompleteProfile =
    "Please complete your profile before starting the experiment."


expTrainingFinishedExpStarts : List (Html.Html msg)
expTrainingFinishedExpStarts =
    [ Html.text "The experiment starts "
    , Html.strong [] [ Html.text "now" ]
    , Html.text "."
    ]


expStandbyTitle : String
expStandbyTitle =
    "Sentence saved!"


expStandbyExplanation : String
expStandbyExplanation =
    "Whenever you're ready, continue with the next sentence."


expUncompletableTitle : String
expUncompletableTitle =
    "Oops, we have no more texts for you!"


expUncompletableExplanation : List (Html.Html msg)
expUncompletableExplanation =
    [ Html.p [] [ Html.text "Either you arrived a bit early, or you've worked real hard and used up all our texts!" ]
    , Html.p []
        [ Html.text "You can wait for more texts to appear. If it's been like this for a long time, don't hesitate to "
        , Html.a
            [ Attributes.href "https://twitter.com/gistrexp"
            , Attributes.title "Contact on Twitter"
            ]
            [ Html.text "contact" ]
        , Html.text " "
        , Html.a
            [ Attributes.href "mailto:sl@mehho.net"
            , Attributes.title "Email the lead developer"
            ]
            [ Html.text "the" ]
        , Html.text " "
        , Html.a
            [ Attributes.href "https://github.com/interpretation-experiment/gistr-app/issues/new"
            , Attributes.title "File a bug on GitHub"
            ]
            [ Html.text "developers" ]
        , Html.text "!"
        ]
    ]


pressCtrlEnter : String
pressCtrlEnter =
    "Press Ctrl+Enter!"


adminCreateBucket : String
adminCreateBucket =
    "Select a bucket in which to create your sentence"


adminAddSentence : String
adminAddSentence =
    "Add a new sentence"


adminTypeSentence : String
adminTypeSentence =
    "Type in your sentence"


adminSentenceCreated : String
adminSentenceCreated =
    "Sentence created!"


bucketPlease : String
bucketPlease =
    "Please select a bucket"


commentSentTitle : String
commentSentTitle =
    "Comment sent!"


commentSent : Html.Html msg
commentSent =
    Html.div []
        [ Html.p [] [ Html.text "Thanks for submitting this, it really helps us!" ]
        , Html.p [] [ Html.text "We'll get back at you if necessary." ]
        ]
