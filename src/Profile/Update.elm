module Profile.Update exposing (update)

import Api
import Auth.Msg as AuthMsg
import Feedback
import Form
import Helpers
import Maybe.Extra exposing (or)
import Model exposing (Model)
import Msg as AppMsg
import Profile.Msg exposing (Msg(..))
import Router
import Strings
import Task
import Types
import Validate


update :
    (Msg -> AppMsg.Msg)
    -> Types.Auth
    -> Msg
    -> Model
    -> ( Model, Cmd AppMsg.Msg, Maybe AppMsg.Msg )
update lift auth msg model =
    case msg of
        {-
           PASSWORD MANAGEMENT
        -}
        ChangePasswordFormInput input ->
            ( { model | password = Form.input input model.password }
            , Cmd.none
            , Nothing
            )

        ChangePasswordFail error ->
            Helpers.feedbackOrUnrecoverable error model <|
                \feedback ->
                    ( { model | password = Form.fail feedback model.password }
                    , Cmd.none
                    , Nothing
                    )

        ChangePassword credentials ->
            ( { model | password = Form.setStatus Form.Sending model.password }
            , Api.changePassword credentials auth
                |> Task.perform
                    (lift << ChangePasswordFail)
                    (lift << ChangePasswordSuccess)
            , Nothing
            )

        ChangePasswordSuccess auth ->
            let
                emptyInput =
                    Types.PasswordCredentials "" "" ""

                feedback =
                    Feedback.globalSuccess model.password.feedback
            in
                ( { model | password = Form.succeed emptyInput feedback model.password }
                , Cmd.none
                , Just (AppMsg.AuthMsg <| AuthMsg.LoginSuccess auth)
                )

        ChangePasswordRecover ->
            let
                maybePrimary =
                    List.filter (\e -> e.primary) auth.user.emails |> List.head

                maybeRecovery =
                    maybePrimary `or` (List.head auth.user.emails)
            in
                case maybeRecovery of
                    Nothing ->
                        -- TODO popup notification
                        ( model
                        , Cmd.none
                        , Nothing
                        )

                    Just email ->
                        -- TODO popup notification
                        ( model
                        , Api.recover email.email
                            |> Task.perform
                                AppMsg.Error
                                (always <| lift ChangePasswordRecoverSuccess)
                        , Nothing
                        )

        ChangePasswordRecoverSuccess ->
            -- TODO popup notification
            ( model
            , Cmd.none
            , Nothing
            )

        {-
           USERNAME MANAGEMENT
        -}
        ChangeUsernameFormInput input ->
            ( { model | username = Form.input input model.username }
            , Cmd.none
            , Nothing
            )

        ChangeUsernameFail error ->
            Helpers.feedbackOrUnrecoverable error model <|
                \feedback ->
                    ( { model | username = Form.fail feedback model.username }
                    , Cmd.none
                    , Nothing
                    )

        ChangeUsername username ->
            let
                user =
                    auth.user
            in
                ( { model | username = Form.setStatus Form.Sending model.username }
                , Api.updateUser { user | username = username } auth
                    |> Task.perform
                        (lift << ChangeUsernameFail)
                        (lift << ChangeUsernameSuccess)
                , Nothing
                )

        ChangeUsernameSuccess user ->
            let
                feedback =
                    Feedback.globalSuccess model.username.feedback
            in
                ( Helpers.updateUser
                    { model | username = Form.succeed "" feedback model.username }
                    user
                , Cmd.none
                , Nothing
                )

        {-
           EMAIL MANAGEMENT
        -}
        RequestEmailVerification email ->
            let
                user =
                    auth.user

                emails =
                    -- Set e.transacting to True on our email
                    List.map (\e -> { e | transacting = e.id == email.id }) user.emails
            in
                ( Helpers.updateUser model { user | emails = emails }
                , Api.requestEmailVerification email auth
                    |> Task.perform
                        AppMsg.Error
                        (always <| lift <| RequestEmailVerificationSuccess email)
                , Nothing
                )

        RequestEmailVerificationSuccess email ->
            -- TODO popup notification
            let
                user =
                    auth.user

                emails =
                    -- Set e.transacting to False on our email,
                    -- and leave the rest untouched
                    List.map
                        (\e -> { e | transacting = (e.id /= email.id) && e.transacting })
                        user.emails
            in
                ( Helpers.updateUser model { user | emails = emails }
                , Cmd.none
                , Nothing
                )

        EmailConfirmationFail error ->
            -- TODO popup notification
            Helpers.feedbackOrUnrecoverable error model <|
                \_ ->
                    ( { model | emailConfirmation = Model.ConfirmationFail }
                    , Cmd.none
                    , Nothing
                    )

        EmailConfirmationSuccess user ->
            -- TODO popup notification
            ( Helpers.updateUser model user
            , Cmd.none
            , Just <| AppMsg.NavigateTo <| Router.Profile Router.Emails
            )

        PrimaryEmail email ->
            let
                user =
                    auth.user

                emails =
                    -- Set e.primary to True on our email and possibly on the other
                    -- primary email, and set e.transacting on all emails
                    List.map (\e -> { e | transacting = True }) user.emails
            in
                ( Helpers.updateUser model { user | emails = emails }
                , Api.updateEmail { email | primary = True } auth
                    |> Task.perform AppMsg.Error (lift << PrimaryEmailSuccess)
                , Nothing
                )

        PrimaryEmailSuccess user ->
            ( Helpers.updateUser model user
            , Cmd.none
            , Nothing
            )

        DeleteEmail email ->
            let
                user =
                    auth.user

                secondaryEmails =
                    List.filter (\e -> (e.id /= email.id) && (not e.primary)) user.emails

                ( emails, fixPrimary ) =
                    case ( email.primary, secondaryEmails ) of
                        ( True, secondaryEmail :: _ ) ->
                            ( List.map (\e -> { e | transacting = True }) user.emails
                            , Api.updateEmail { secondaryEmail | primary = True } auth
                            )

                        _ ->
                            ( List.map
                                (\e -> { e | transacting = (e.id == email.id) })
                                user.emails
                            , Task.succeed user
                            )
            in
                ( Helpers.updateUser model { user | emails = emails }
                , Task.sequence [ fixPrimary, Api.deleteEmail email auth ]
                    |> Task.perform AppMsg.Error (lift << DeleteEmailSuccess)
                , Nothing
                )

        DeleteEmailSuccess user ->
            -- TODO popup notification
            ( Helpers.updateUser model user
            , Cmd.none
            , Nothing
            )

        AddEmailFormInput input ->
            ( { model | emails = Form.input input model.emails }
            , Cmd.none
            , Nothing
            )

        AddEmailFail error ->
            Helpers.feedbackOrUnrecoverable error model <|
                \feedback ->
                    ( { model | emails = Form.fail feedback model.emails }
                    , Cmd.none
                    , Nothing
                    )

        AddEmail input ->
            ( { model | emails = Form.setStatus Form.Sending model.emails }
            , Api.addEmail input auth
                |> Task.perform (lift << AddEmailFail) (lift << AddEmailSuccess)
            , Nothing
            )

        AddEmailSuccess user ->
            -- TODO: popup notification
            let
                feedback =
                    Feedback.globalSuccess model.emails.feedback
            in
                ( Helpers.updateUser
                    { model | emails = Form.succeed "" feedback model.emails }
                    user
                , Cmd.none
                , Nothing
                )

        {-
           QUESTIONNAIRE
        -}
        QuestionnaireFormInput input ->
            ( { model | questionnaire = Form.input input model.questionnaire }
            , Cmd.none
            , Nothing
            )

        QuestionnaireFormConfirm input ->
            let
                informedValidator =
                    [ .informedHow
                        >> Helpers.ifShorterThan 5
                            ( "informedHow", Strings.fiveCharactersPlease )
                    , .informedWhat
                        >> Helpers.ifShorterThan 5
                            ( "informedWhat", Strings.fiveCharactersPlease )
                    ]
                        |> Validate.all

                feedback =
                    [ .age
                        >> Validate.ifNotInt ( "age", Strings.intPlease )
                    , .gender
                        >> Validate.ifBlank ( "gender", Strings.genderPlease )
                    , Helpers.ifThenValidate .informed informedValidator
                    , .jobType
                        >> Validate.ifBlank ( "jobType", Strings.jobTypePlease )
                    , .jobFreetext
                        >> Helpers.ifShorterThan 5
                            ( "jobFreetext", Strings.fiveCharactersPlease )
                    ]
                        |> Validate.all
                        |> Feedback.fromValidator input
            in
                if Feedback.isEmpty feedback then
                    ( { model | questionnaire = Form.confirm input model.questionnaire }
                    , Cmd.none
                    , Nothing
                    )
                else
                    ( { model | questionnaire = Form.fail feedback model.questionnaire }
                    , Cmd.none
                    , Nothing
                    )

        QuestionnaireFormCorrect ->
            ( { model | questionnaire = Form.setStatus Form.Entering model.questionnaire }
            , Cmd.none
            , Nothing
            )

        QuestionnaireFormSubmit input ->
            let
                processedInput =
                    { input
                        | informedHow =
                            if input.informed then
                                input.informedHow
                            else
                                "-----"
                        , informedWhat =
                            if input.informed then
                                input.informedWhat
                            else
                                "-----"
                    }
            in
                ( { model | questionnaire = Form.setStatus Form.Sending model.questionnaire }
                , Api.postQuestionnaire processedInput auth
                    |> Task.perform
                        (lift << QuestionnaireFormFail)
                        (lift << QuestionnaireFormSuccess)
                , Nothing
                )

        QuestionnaireFormFail error ->
            Helpers.feedbackOrUnrecoverable error model <|
                \feedback ->
                    ( { model | questionnaire = Form.fail feedback model.questionnaire }
                    , Cmd.none
                    , Nothing
                    )

        QuestionnaireFormSuccess profile ->
            -- TODO: popup notification
            ( Helpers.updateProfile model profile
            , Cmd.none
            , Just <| AppMsg.NavigateTo <| Router.Profile Router.Dashboard
            )
