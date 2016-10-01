module View.Profile exposing (view)

import Animation
import Feedback
import Form
import Helpers
import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Lifecycle
import Model exposing (Model)
import Msg exposing (Msg(..))
import Router
import Strings
import Types


view : Model -> Router.ProfileRoute -> Html.Html Msg
view model route =
    let
        contents =
            case model.auth of
                Types.Authenticated { user } ->
                    [ menu route, body model route user ]

                Types.Authenticating ->
                    [ Helpers.loading ]

                Types.Anonymous ->
                    [ Helpers.notAuthed ]
    in
        Html.div [] ((header model) :: contents)


header : Model -> Html.Html Msg
header model =
    let
        logout =
            case model.auth of
                Types.Authenticated auth ->
                    Html.div []
                        [ Html.text "Signed in as "
                        , Html.strong [] [ Html.text auth.user.username ]
                        , Helpers.evButton [] Logout "Logout"
                        ]

                _ ->
                    Html.span [] []
    in
        Html.div []
            [ Helpers.navButton Router.Home "Back"
            , logout
            , Html.h1 [] [ Html.text "Profile" ]
            ]


menu : Router.ProfileRoute -> Html.Html Msg
menu route =
    Html.ul []
        [ Html.li [] [ Helpers.navButton (Router.Profile Router.Dashboard) "Dashboard" ]
        , Html.li [] [ Helpers.navButton (Router.Profile Router.Settings) "Settings" ]
        , Html.li [] [ Helpers.navButton (Router.Profile Router.Emails) "Emails" ]
        ]


body : Model -> Router.ProfileRoute -> Types.User -> Html.Html Msg
body model route user =
    case route of
        Router.Dashboard ->
            dashboard user.profile

        Router.Settings ->
            Html.div []
                [ passwordChange model.password
                , usernameChange model.username
                ]

        Router.Emails ->
            emails model.emails user.emails

        Router.Confirm key ->
            emailConfirmation model.emailConfirmation key


dashboard : Types.Profile -> Html.Html Msg
dashboard profile =
    Html.div []
        [ lifecycle profile
        , questionnaireSummary profile.questionnaireId
        , wordSpanSummary profile.wordSpanId
        ]


lifecycle : Types.Profile -> Html.Html Msg
lifecycle profile =
    let
        description preliminary =
            case preliminary of
                Lifecycle.ProfilePreliminary (Lifecycle.Questionnaire) ->
                    [ Html.text Strings.fillQuestionnaire ]

                Lifecycle.ProfilePreliminary (Lifecycle.WordSpan) ->
                    [ Html.text Strings.testWordSpan ]

                Lifecycle.Training ->
                    Strings.startExperiment
    in
        case Lifecycle.state profile of
            Lifecycle.Preliminaries remaining ->
                case List.partition Lifecycle.isProfilePreliminary remaining of
                    ( head :: tail, _ ) ->
                        Html.div []
                            [ Html.text Strings.completeProfile
                            , Html.ul [] <|
                                List.map
                                    (\t -> Html.li [] (description t))
                                    (head :: tail)
                            ]

                    ( [], remainingExp ) ->
                        Html.div [] <|
                            List.concat <|
                                List.map (\t -> description t) remainingExp

            Lifecycle.Experiment ->
                Html.div [] Strings.profileComplete


questionnaireSummary : Maybe Int -> Html.Html Msg
questionnaireSummary maybeId =
    case maybeId of
        Nothing ->
            Html.p []
                [ Html.text "Questionnaire — Not yet done"
                , Helpers.navButton (Router.Profile Router.Dashboard) "Fill the questionnaire"
                  -- TODO set route to questionnaire
                ]

        Just _ ->
            Html.p [] [ Html.text "Questionnaire — Done" ]


wordSpanSummary : Maybe Int -> Html.Html Msg
wordSpanSummary maybeId =
    case maybeId of
        Nothing ->
            Html.p []
                [ Html.text "Word span test — Not yet done"
                , Helpers.navButton (Router.Profile Router.Dashboard) "Pass the test"
                  -- TODO set route to wordSpan
                ]

        Just _ ->
            Html.p [] [ Html.text "Word span test — Done" ]


passwordChange : Form.Model Types.PasswordCredentials -> Html.Html Msg
passwordChange { input, feedback, status } =
    Html.div []
        [ Html.h2 [] [ Html.text "Change password" ]
        , Html.form [ Events.onSubmit (Msg.ChangePassword input) ]
            [ Html.div []
                [ Html.label [ Attributes.for "inputOldPassword" ] [ Html.text "Old password" ]
                , Html.input
                    [ Attributes.id "inputOldPassword"
                    , Attributes.disabled (status == Form.Sending)
                    , Attributes.placeholder "Your old password"
                    , Attributes.type' "password"
                    , Attributes.value input.oldPassword
                    , Events.onInput (Msg.ChangePasswordFormInput << \o -> { input | oldPassword = o })
                    ]
                    []
                , Html.span [] [ Html.text (Feedback.getError "oldPassword" feedback) ]
                ]
            , Html.div []
                [ Html.label [ Attributes.for "inputPassword1" ] [ Html.text "New password" ]
                , Html.input
                    [ Attributes.id "inputPassword1"
                    , Attributes.disabled (status == Form.Sending)
                    , Attributes.placeholder "ubA1oh"
                    , Attributes.type' "password"
                    , Attributes.value input.password1
                    , Events.onInput (Msg.ChangePasswordFormInput << \p -> { input | password1 = p })
                    ]
                    []
                , Html.span [] [ Html.text (Feedback.getError "password1" feedback) ]
                ]
            , Html.div []
                [ Html.label [ Attributes.for "inputPassword2" ] [ Html.text "Confirm new password" ]
                , Html.input
                    [ Attributes.id "inputPassword2"
                    , Attributes.disabled (status == Form.Sending)
                    , Attributes.placeholder "ubA1oh"
                    , Attributes.type' "password"
                    , Attributes.value input.password2
                    , Events.onInput (Msg.ChangePasswordFormInput << \p -> { input | password2 = p })
                    ]
                    []
                , Html.span [] [ Html.text (Feedback.getError "password2" feedback) ]
                ]
            , Html.div []
                [ Html.span [] [ Html.text (Feedback.getError "global" feedback) ]
                , Html.button
                    [ Attributes.type' "submit"
                    , Attributes.disabled (status == Form.Sending)
                    ]
                    [ Html.text "Update password" ]
                , Html.span
                    (Animation.render <| Feedback.getSuccess "global" feedback)
                    [ Html.text Strings.passwordSaved ]
                , Helpers.evA "#" Msg.ChangePasswordRecover "I forgot my current password"
                ]
            ]
        ]


usernameChange : Form.Model String -> Html.Html Msg
usernameChange { input, feedback, status } =
    Html.div []
        [ Html.h2 [] [ Html.text "Change username" ]
        , Html.form [ Events.onSubmit (ChangeUsername input) ]
            [ Html.span [] [ Html.text (Feedback.getError "global" feedback) ]
            , Html.input
                [ Attributes.id "inputUsername"
                , Attributes.disabled (status == Form.Sending)
                , Attributes.type' "text"
                , Attributes.value input
                , Events.onInput ChangeUsernameFormInput
                ]
                []
            , Html.button
                [ Attributes.type' "submit"
                , Attributes.disabled (status == Form.Sending)
                ]
                [ Html.text "Update username" ]
            , Html.span
                (Animation.render <| Feedback.getSuccess "global" feedback)
                [ Html.text Strings.usernameSaved ]
            ]
        ]


emails : Form.Model String -> List Types.Email -> Html.Html Msg
emails { input, feedback, status } emails' =
    let
        emailList =
            case emails' of
                [] ->
                    Html.p [] [ Html.text "You have no emails configured" ]

                _ ->
                    Html.ul [] (List.map email emails')
    in
        Html.div []
            [ Html.h2 [] [ Html.text "Email" ]
            , Html.p []
                [ Html.text "Your "
                , Html.strong [] [ Html.text "primary email address" ]
                , Html.text " is used for account-related information and password reset."
                ]
            , emailList
            , Html.h2 [] [ Html.text "Add an email address" ]
            , Html.form [ Events.onSubmit (AddEmail input) ]
                [ Html.span [] [ Html.text (Feedback.getError "global" feedback) ]
                , Html.input
                    [ Attributes.id "inputEmail"
                    , Attributes.disabled (status == Form.Sending)
                    , Attributes.type' "email"
                    , Attributes.value input
                    , Events.onInput AddEmailFormInput
                    ]
                    []
                , Html.button
                    [ Attributes.type' "submit"
                    , Attributes.disabled (status == Form.Sending)
                    ]
                    [ Html.text "Add" ]
                , Html.span
                    (Animation.render <| Feedback.getSuccess "global" feedback)
                    [ Html.text Strings.emailAdded ]
                ]
            ]


email : Types.Email -> Html.Html Msg
email email' =
    let
        disabled =
            Attributes.disabled email'.transacting

        primary =
            if email'.primary then
                [ Html.span [] [ Html.text "Primary" ] ]
            else
                []

        verified =
            if email'.verified then
                []
            else
                [ Html.span [] [ Html.text "Unverified" ]
                , Helpers.evButton [ disabled ] (RequestEmailVerification email') "Send verification email"
                ]

        setPrimary =
            if email'.verified && (not email'.primary) then
                [ Helpers.evButton [ disabled ] (PrimaryEmail email') "Set as primary" ]
            else
                []
    in
        Html.div []
            ([ Html.span [] [ Html.text email'.email ] ]
                ++ primary
                ++ verified
                ++ setPrimary
                ++ [ Helpers.evButton [ disabled ] (DeleteEmail email') "Delete" ]
            )


emailConfirmation : Model.EmailConfirmationModel -> String -> Html.Html Msg
emailConfirmation model key =
    case model of
        Model.SendingConfirmation ->
            Html.h2 [] [ Html.text "Confirming your email address..." ]

        Model.ConfirmationFail ->
            Html.div []
                [ Html.h2 [] [ Html.text "Email confirmation failed" ]
                , Html.p []
                    [ Html.text "There was a problem. Did you use the "
                    , Html.strong [] [ Html.text "last verification email" ]
                    , Html.text " you received?"
                    ]
                ]
