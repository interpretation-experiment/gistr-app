module Profile.View exposing (view)

import Animation
import Auth.Msg as AuthMsg
import Feedback
import Form
import Helpers
import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Lifecycle
import Model exposing (Model)
import Msg as AppMsg
import Profile.Msg exposing (Msg(..))
import Profile.View.Questionnaire as Questionnaire
import Profile.View.WordSpan as WordSpan
import Router
import Store
import Strings
import Styles exposing (class, classList, id)
import Types


view : (Msg -> AppMsg.Msg) -> Model -> Router.ProfileRoute -> List (Html.Html AppMsg.Msg)
view lift model route =
    let
        contents =
            case model.auth of
                Types.Authenticated auth ->
                    [ Html.nav [] (menu route)
                    , Html.div [] (body lift model route auth)
                    ]

                Types.Authenticating ->
                    [ Html.div [] [ Helpers.loading ] ]

                Types.Anonymous ->
                    [ Html.div [] [ Helpers.notAuthed ] ]
    in
        [ Html.header [] (header model)
        , Html.main_ [] [ Html.div [ class [ Styles.Normal ] ] contents ]
        ]


header : Model -> List (Html.Html AppMsg.Msg)
header model =
    let
        logout =
            case model.auth of
                Types.Authenticated auth ->
                    [ Html.text "Signed in as "
                    , Html.strong [] [ Html.text auth.user.username ]
                    , Html.text " — "
                    , Helpers.evButton
                        [ class [ Styles.Btn ] ]
                        (AppMsg.AuthMsg AuthMsg.Logout)
                        "Sign out"
                    ]

                _ ->
                    []
    in
        [ Html.nav [] [ Helpers.navIcon [ class [ Styles.IconBig ] ] Router.Home "home" ]
        , Html.h1 [] [ Html.text "Profile" ]
        , Html.div [ class [ Styles.Meta ] ] logout
        ]


menu : Router.ProfileRoute -> List (Html.Html AppMsg.Msg)
menu current =
    let
        item route text =
            Helpers.navA
                [ classList [ ( Styles.Active, (Router.Profile current) == route ) ] ]
                route
                text
    in
        [ Html.div [ class [ Styles.Menu ] ]
            [ item (Router.Profile Router.Dashboard) "Dashboard"
            , item (Router.Profile Router.Settings) "Settings"
            , item (Router.Profile Router.Emails) "Emails"
            ]
        ]


body :
    (Msg -> AppMsg.Msg)
    -> Model
    -> Router.ProfileRoute
    -> Types.Auth
    -> List (Html.Html AppMsg.Msg)
body lift model route auth =
    case route of
        Router.Dashboard ->
            dashboard model auth.meta auth.user.profile

        Router.Settings ->
            [ passwordChange lift model.password
            , usernameChange lift model.username auth
            ]

        Router.Emails ->
            [ Html.div [ class [ Styles.Well ] ]
                (emails lift model.emails auth.user.emails)
            ]

        Router.Confirm key ->
            [ Html.div [ class [ Styles.Well ] ]
                (emailConfirmation model.emailConfirmation key)
            ]

        Router.Questionnaire ->
            [ Html.div [ class [ Styles.Well ] ]
                (Questionnaire.view lift model auth.meta)
            ]

        Router.WordSpan ->
            [ Html.div [ class [ Styles.Well ] ]
                WordSpan.view
            ]


dashboard : Model -> Types.Meta -> Types.Profile -> List (Html.Html AppMsg.Msg)
dashboard model meta profile =
    [ lifecycle meta profile
    , Html.div [ class [ Styles.Well ] ] [ questionnaireSummary profile.questionnaireId ]
    , Html.div [ class [ Styles.Well ] ] [ wordSpanSummary profile.wordSpanId model.store ]
    ]


lifecycle : Types.Meta -> Types.Profile -> Html.Html AppMsg.Msg
lifecycle meta profile =
    let
        description test =
            case test of
                Lifecycle.Questionnaire ->
                    [ Html.text Strings.fillQuestionnaire ]

                Lifecycle.WordSpan ->
                    [ Html.text Strings.testWordSpan ]

        describeTests tests =
            Html.div []
                [ Html.text Strings.completeProfile
                , Html.ul [] <|
                    List.map (\t -> Html.li [] (description t)) tests
                ]
    in
        case Lifecycle.state meta profile of
            Lifecycle.Training tests ->
                if List.length tests == 0 then
                    Html.div [] Strings.startTraining
                else
                    describeTests tests

            Lifecycle.Experiment tests ->
                if List.length tests == 0 then
                    Html.div [] Strings.profileComplete
                else
                    describeTests tests

            Lifecycle.Done ->
                -- TODO
                Html.div [] [ Html.text "TODO: exp done! Show completion code if we have a prolific id. Show stats and point to profile/tree exploration." ]


questionnaireSummary : Maybe Int -> Html.Html AppMsg.Msg
questionnaireSummary maybeId =
    case maybeId of
        Nothing ->
            Html.h4 []
                [ Html.text "Questionnaire — Not yet done "
                , Helpers.navButton
                    [ class [ Styles.Btn, Styles.BtnPrimary ] ]
                    (Router.Profile Router.Questionnaire)
                    "Fill the questionnaire"
                ]

        Just _ ->
            Html.h4 [] [ Html.text "Questionnaire — ✓ Done" ]


wordSpanSummary : Maybe Int -> Store.Store -> Html.Html AppMsg.Msg
wordSpanSummary maybeId store =
    case maybeId of
        Nothing ->
            Html.h4 []
                [ Html.text "Word span test — Not yet done "
                , Helpers.navButton
                    [ class [ Styles.Btn, Styles.BtnPrimary ] ]
                    (Router.Profile Router.WordSpan)
                    "Pass the test"
                ]

        Just id ->
            let
                detail =
                    case store.wordSpan of
                        Nothing ->
                            ""

                        Just wordSpan ->
                            " " ++ (toString wordSpan.span) ++ " words"
            in
                Html.h4 [] [ Html.text ("Word span test — ✓" ++ detail) ]


passwordChange :
    (Msg -> AppMsg.Msg)
    -> Form.Model Types.PasswordCredentials
    -> Html.Html AppMsg.Msg
passwordChange lift { input, feedback, status } =
    Html.div [ class [ Styles.Well ] ]
        [ Html.h2 [] [ Html.text "Change password" ]
        , Html.form
            [ class [ Styles.FormPage ], Events.onSubmit <| lift (ChangePassword input) ]
            [ Html.div
                [ class [ Styles.FormBlock ]
                , Helpers.feedbackStyles "oldPassword" feedback
                ]
                [ Html.label
                    [ Attributes.for "inputOldPassword" ]
                    [ Html.text "Old password" ]
                , Html.div [ class [ Styles.Input, Styles.Label ] ]
                    [ Html.span [ class [ Styles.Label ] ] [ Helpers.icon "lock" ]
                    , Html.input
                        [ Attributes.id "inputOldPassword"
                        , Attributes.disabled (status /= Form.Entering)
                        , Attributes.placeholder "Your old password"
                        , Attributes.type_ "password"
                        , Attributes.value input.oldPassword
                        , Events.onInput <|
                            lift
                                << (ChangePasswordFormInput
                                        << \o -> { input | oldPassword = o }
                                   )
                        ]
                        []
                    ]
                , Html.div [] [ Html.text (Feedback.getError "oldPassword" feedback) ]
                ]
            , Html.div
                [ class [ Styles.FormBlock ]
                , Helpers.feedbackStyles "password1" feedback
                ]
                [ Html.label [ Attributes.for "inputPassword1" ]
                    [ Html.text "New password" ]
                , Html.div [ class [ Styles.Input, Styles.Label ] ]
                    [ Html.span [ class [ Styles.Label ] ] [ Helpers.icon "lock" ]
                    , Html.input
                        [ Attributes.id "inputPassword1"
                        , Attributes.disabled (status /= Form.Entering)
                        , Attributes.placeholder "ubA1oh"
                        , Attributes.type_ "password"
                        , Attributes.value input.password1
                        , Events.onInput <|
                            lift
                                << (ChangePasswordFormInput
                                        << \p -> { input | password1 = p }
                                   )
                        ]
                        []
                    ]
                , Html.div [] [ Html.text (Feedback.getError "password1" feedback) ]
                ]
            , Html.div
                [ class [ Styles.FormBlock ]
                , Helpers.feedbackStyles "password2" feedback
                ]
                [ Html.label
                    [ Attributes.for "inputPassword2" ]
                    [ Html.text "Confirm new password" ]
                , Html.div [ class [ Styles.Input, Styles.Label ] ]
                    [ Html.span [ class [ Styles.Label ] ] [ Helpers.icon "lock" ]
                    , Html.input
                        [ Attributes.id "inputPassword2"
                        , Attributes.disabled (status /= Form.Entering)
                        , Attributes.placeholder "ubA1oh"
                        , Attributes.type_ "password"
                        , Attributes.value input.password2
                        , Events.onInput <|
                            lift
                                << (ChangePasswordFormInput
                                        << \p -> { input | password2 = p }
                                   )
                        ]
                        []
                    ]
                , Html.div [] [ Html.text (Feedback.getError "password2" feedback) ]
                ]
            , Html.div []
                [ Html.div [ class [ Styles.Error ] ]
                    [ Html.text (Feedback.getError "global" feedback) ]
                , Html.button
                    [ Attributes.type_ "submit"
                    , Attributes.disabled (status /= Form.Entering)
                    , class [ Styles.Btn, Styles.BtnPrimary ]
                    ]
                    [ Html.text "Update password" ]
                , Helpers.evButton
                    [ class [ Styles.BtnLink ] ]
                    (lift ChangePasswordRecover)
                    "I forgot my current password"
                , Html.span
                    ((Animation.render <| Feedback.getSuccess "global" feedback)
                        ++ [ class [ Styles.BadgeSuccess ] ]
                    )
                    [ Html.text Strings.passwordSaved ]
                ]
            ]
        ]


usernameChange :
    (Msg -> AppMsg.Msg)
    -> Form.Model String
    -> Types.Auth
    -> Html.Html AppMsg.Msg
usernameChange lift { input, feedback, status } { user } =
    Html.div [ class [ Styles.Well ] ]
        [ Html.h2 [] [ Html.text "Change username" ]
        , Html.form
            [ class [ Styles.FormInline ], Events.onSubmit <| lift (ChangeUsername input) ]
            [ Html.div
                [ class [ Styles.Input, Styles.Label ]
                , Helpers.feedbackStyles "global" feedback
                ]
                [ Html.span [ class [ Styles.Label ] ] [ Helpers.icon "user" ]
                , Html.input
                    [ Attributes.id "inputUsername"
                    , Attributes.placeholder user.username
                    , Attributes.disabled (status /= Form.Entering)
                    , Attributes.type_ "text"
                    , Attributes.value input
                    , Events.onInput (lift << ChangeUsernameFormInput)
                    ]
                    []
                ]
            , Html.button
                [ Attributes.type_ "submit"
                , Attributes.disabled (status /= Form.Entering)
                , class [ Styles.Btn, Styles.BtnPrimary ]
                ]
                [ Html.text "Update username" ]
            , Html.span
                ((Animation.render <| Feedback.getSuccess "global" feedback)
                    ++ [ class [ Styles.BadgeSuccess ] ]
                )
                [ Html.text Strings.usernameSaved ]
            , Html.span [ class [ Styles.Error ] ] [ Html.text (Feedback.getError "global" feedback) ]
            ]
        ]


emails :
    (Msg -> AppMsg.Msg)
    -> Form.Model String
    -> List Types.Email
    -> List (Html.Html AppMsg.Msg)
emails lift { input, feedback, status } emails_ =
    let
        emailList =
            case emails_ of
                [] ->
                    Html.p [] [ Html.text "You have no emails configured." ]

                _ ->
                    Html.div [] (List.map (email lift) emails_)
    in
        [ Html.h2 [] [ Html.text "Email" ]
        , Html.p []
            [ Html.text "Your "
            , Html.strong [] [ Html.text "primary email address" ]
            , Html.text " is used for account-related information and password reset."
            ]
        , emailList
        , Html.h2 [] [ Html.text "Add an email address" ]
        , Html.form
            [ class [ Styles.FormInline ], Events.onSubmit <| lift (AddEmail input) ]
            [ Html.div
                [ class [ Styles.Input, Styles.Label ]
                , Helpers.feedbackStyles "global" feedback
                ]
                [ Html.span [ class [ Styles.Label ] ] [ Helpers.icon "envelope" ]
                , Html.input
                    [ Attributes.id "inputEmail"
                    , Attributes.disabled (status /= Form.Entering)
                    , Attributes.type_ "email"
                    , Attributes.value input
                    , Events.onInput (lift << AddEmailFormInput)
                    ]
                    []
                ]
            , Html.button
                [ Attributes.type_ "submit"
                , Attributes.disabled (status /= Form.Entering)
                , class [ Styles.Btn, Styles.BtnPrimary ]
                ]
                [ Html.text "Add" ]
            , Html.span
                ((Animation.render <| Feedback.getSuccess "global" feedback)
                    ++ [ class [ Styles.BadgeSuccess ] ]
                )
                [ Html.text Strings.emailAdded ]
            , Html.span [ class [ Styles.Error ] ]
                [ Html.text (Feedback.getError "global" feedback) ]
            ]
        ]


email : (Msg -> AppMsg.Msg) -> Types.Email -> Html.Html AppMsg.Msg
email lift email_ =
    let
        disabled =
            Attributes.disabled email_.transacting

        primary =
            if email_.primary then
                [ Html.span [ class [ Styles.BadgeSuccess ] ] [ Html.text "Primary" ] ]
            else
                []

        verified =
            if email_.verified then
                []
            else
                [ Html.span [ class [ Styles.BadgeDefault ] ] [ Html.text "Unverified" ]
                , Helpers.evButton
                    [ disabled, class [ Styles.Btn, Styles.BtnSmall ] ]
                    (lift <| VerifyEmail email_)
                    "Send verification email"
                ]

        setPrimary =
            if email_.verified && (not email_.primary) then
                [ Helpers.evButton
                    [ disabled, class [ Styles.Btn, Styles.BtnSmall ] ]
                    (lift <| PrimaryEmail email_)
                    "Set as primary"
                ]
            else
                []
    in
        Html.div [ class [ Styles.EmailLine ] ]
            ([ Html.span [] [ Html.text email_.email ] ]
                ++ primary
                ++ verified
                ++ setPrimary
                ++ [ Helpers.evIconButton
                        [ disabled, class [ Styles.IconSmall ] ]
                        (lift <| DeleteEmail email_)
                        "trash"
                   ]
            )


emailConfirmation : Model.EmailConfirmationModel -> String -> List (Html.Html AppMsg.Msg)
emailConfirmation model key =
    case model of
        Model.SendingConfirmation ->
            [ Html.h2 [] [ Html.text "Confirming your email address..." ] ]

        Model.ConfirmationFail ->
            [ Html.h2 [] [ Html.text "Email confirmation failed" ]
            , Html.p []
                [ Html.text "There was a problem. Did you use the "
                , Html.strong [] [ Html.text "last verification email" ]
                , Html.text " you received?"
                ]
            ]
