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
                    , Helpers.evButton [] (AppMsg.AuthMsg AuthMsg.Logout) "Sign out"
                    ]

                _ ->
                    []
    in
        [ Html.nav [] [ Helpers.navButton Router.Home "Back" ]
        , Html.h1 [] [ Html.text "Profile" ]
        , Html.div [ class [ Styles.Meta ] ] logout
        ]


menu : Router.ProfileRoute -> List (Html.Html AppMsg.Msg)
menu route =
    [ Html.div [] [ Helpers.navButton (Router.Profile Router.Dashboard) "Dashboard" ]
    , Html.div [] [ Helpers.navButton (Router.Profile Router.Settings) "Settings" ]
    , Html.div [] [ Helpers.navButton (Router.Profile Router.Emails) "Emails" ]
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
            , usernameChange lift model.username
            ]

        Router.Emails ->
            emails lift model.emails auth.user.emails

        Router.Confirm key ->
            emailConfirmation model.emailConfirmation key

        Router.Questionnaire ->
            Questionnaire.view lift model auth.meta

        Router.WordSpan ->
            WordSpan.view


dashboard : Model -> Types.Meta -> Types.Profile -> List (Html.Html AppMsg.Msg)
dashboard model meta profile =
    [ lifecycle meta profile
    , questionnaireSummary profile.questionnaireId
    , wordSpanSummary profile.wordSpanId model.store
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
            Html.p []
                [ Html.text "Questionnaire — Not yet done"
                , Helpers.navButton (Router.Profile Router.Questionnaire) "Fill the questionnaire"
                ]

        Just _ ->
            Html.p [] [ Html.text "Questionnaire — ✓ Done" ]


wordSpanSummary : Maybe Int -> Store.Store -> Html.Html AppMsg.Msg
wordSpanSummary maybeId store =
    case maybeId of
        Nothing ->
            Html.p []
                [ Html.text "Word span test — Not yet done"
                , Helpers.navButton (Router.Profile Router.WordSpan) "Pass the test"
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
                Html.p [] [ Html.text ("Word span test — ✓" ++ detail) ]


passwordChange : (Msg -> AppMsg.Msg) -> Form.Model Types.PasswordCredentials -> Html.Html AppMsg.Msg
passwordChange lift { input, feedback, status } =
    Html.div []
        [ Html.h2 [] [ Html.text "Change password" ]
        , Html.form [ Events.onSubmit <| lift (ChangePassword input) ]
            [ Html.div []
                [ Html.label [ Attributes.for "inputOldPassword" ] [ Html.text "Old password" ]
                , Html.input
                    [ Attributes.id "inputOldPassword"
                    , Attributes.disabled (status /= Form.Entering)
                    , Attributes.placeholder "Your old password"
                    , Attributes.type_ "password"
                    , Attributes.value input.oldPassword
                    , Events.onInput <| lift << (ChangePasswordFormInput << \o -> { input | oldPassword = o })
                    ]
                    []
                , Html.span [] [ Html.text (Feedback.getError "oldPassword" feedback) ]
                ]
            , Html.div []
                [ Html.label [ Attributes.for "inputPassword1" ] [ Html.text "New password" ]
                , Html.input
                    [ Attributes.id "inputPassword1"
                    , Attributes.disabled (status /= Form.Entering)
                    , Attributes.placeholder "ubA1oh"
                    , Attributes.type_ "password"
                    , Attributes.value input.password1
                    , Events.onInput <| lift << (ChangePasswordFormInput << \p -> { input | password1 = p })
                    ]
                    []
                , Html.span [] [ Html.text (Feedback.getError "password1" feedback) ]
                ]
            , Html.div []
                [ Html.label [ Attributes.for "inputPassword2" ] [ Html.text "Confirm new password" ]
                , Html.input
                    [ Attributes.id "inputPassword2"
                    , Attributes.disabled (status /= Form.Entering)
                    , Attributes.placeholder "ubA1oh"
                    , Attributes.type_ "password"
                    , Attributes.value input.password2
                    , Events.onInput <| lift << (ChangePasswordFormInput << \p -> { input | password2 = p })
                    ]
                    []
                , Html.span [] [ Html.text (Feedback.getError "password2" feedback) ]
                ]
            , Html.div []
                [ Html.span [] [ Html.text (Feedback.getError "global" feedback) ]
                , Html.button
                    [ Attributes.type_ "submit"
                    , Attributes.disabled (status /= Form.Entering)
                    ]
                    [ Html.text "Update password" ]
                , Html.span
                    (Animation.render <| Feedback.getSuccess "global" feedback)
                    [ Html.text Strings.passwordSaved ]
                , Helpers.evA "#" (lift ChangePasswordRecover) "I forgot my current password"
                ]
            ]
        ]


usernameChange : (Msg -> AppMsg.Msg) -> Form.Model String -> Html.Html AppMsg.Msg
usernameChange lift { input, feedback, status } =
    Html.div []
        [ Html.h2 [] [ Html.text "Change username" ]
        , Html.form [ Events.onSubmit <| lift (ChangeUsername input) ]
            [ Html.span [] [ Html.text (Feedback.getError "global" feedback) ]
            , Html.input
                [ Attributes.id "inputUsername"
                , Attributes.disabled (status /= Form.Entering)
                , Attributes.type_ "text"
                , Attributes.value input
                , Events.onInput (lift << ChangeUsernameFormInput)
                ]
                []
            , Html.button
                [ Attributes.type_ "submit"
                , Attributes.disabled (status /= Form.Entering)
                ]
                [ Html.text "Update username" ]
            , Html.span
                (Animation.render <| Feedback.getSuccess "global" feedback)
                [ Html.text Strings.usernameSaved ]
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
                    Html.p [] [ Html.text "You have no emails configured" ]

                _ ->
                    Html.ul [] (List.map (email lift) emails_)
    in
        [ Html.h2 [] [ Html.text "Email" ]
        , Html.p []
            [ Html.text "Your "
            , Html.strong [] [ Html.text "primary email address" ]
            , Html.text " is used for account-related information and password reset."
            ]
        , emailList
        , Html.h2 [] [ Html.text "Add an email address" ]
        , Html.form [ Events.onSubmit <| lift (AddEmail input) ]
            [ Html.span [] [ Html.text (Feedback.getError "global" feedback) ]
            , Html.input
                [ Attributes.id "inputEmail"
                , Attributes.disabled (status /= Form.Entering)
                , Attributes.type_ "email"
                , Attributes.value input
                , Events.onInput (lift << AddEmailFormInput)
                ]
                []
            , Html.button
                [ Attributes.type_ "submit"
                , Attributes.disabled (status /= Form.Entering)
                ]
                [ Html.text "Add" ]
            , Html.span
                (Animation.render <| Feedback.getSuccess "global" feedback)
                [ Html.text Strings.emailAdded ]
            ]
        ]


email : (Msg -> AppMsg.Msg) -> Types.Email -> Html.Html AppMsg.Msg
email lift email_ =
    let
        disabled =
            Attributes.disabled email_.transacting

        primary =
            if email_.primary then
                [ Html.span [] [ Html.text "Primary" ] ]
            else
                []

        verified =
            if email_.verified then
                []
            else
                [ Html.span [] [ Html.text "Unverified" ]
                , Helpers.evButton [ disabled ] (lift <| VerifyEmail email_) "Send verification email"
                ]

        setPrimary =
            if email_.verified && (not email_.primary) then
                [ Helpers.evButton [ disabled ] (lift <| PrimaryEmail email_) "Set as primary" ]
            else
                []
    in
        Html.div []
            ([ Html.span [] [ Html.text email_.email ] ]
                ++ primary
                ++ verified
                ++ setPrimary
                ++ [ Helpers.evButton [ disabled ] (lift <| DeleteEmail email_) "Delete" ]
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
