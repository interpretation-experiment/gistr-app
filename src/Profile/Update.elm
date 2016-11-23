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

        ChangePassword credentials ->
            ( { model | password = Form.setStatus Form.Sending model.password }
            , Api.changePassword auth credentials
                |> Task.attempt (lift << ChangePasswordResult)
            , Nothing
            )

        ChangePasswordResult (Ok auth) ->
            let
                emptyInput =
                    Types.PasswordCredentials "" "" ""

                feedback =
                    Feedback.globalSuccess model.password.feedback
            in
                ( { model | password = Form.succeed emptyInput feedback model.password }
                , Cmd.none
                , Just <| AppMsg.AuthMsg <| AuthMsg.LoginResult <| Ok auth
                )

        ChangePasswordResult (Err error) ->
            Helpers.extractFeedback error
                model
                [ ( "old_password", "oldPassword" )
                , ( "new_password1", "password1" )
                , ( "new_password2", "password2" )
                ]
            <|
                \feedback ->
                    ( { model | password = Form.fail feedback model.password }
                    , Cmd.none
                    , Nothing
                    )

        ChangePasswordRecover ->
            let
                maybePrimary =
                    List.filter (\e -> e.primary) auth.user.emails |> List.head

                maybeRecovery =
                    maybePrimary |> or (List.head auth.user.emails)
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
                            |> Task.attempt (lift << ChangePasswordRecoverResult)
                        , Nothing
                        )

        ChangePasswordRecoverResult (Ok ()) ->
            -- TODO popup notification
            ( model
            , Cmd.none
            , Nothing
            )

        ChangePasswordRecoverResult (Err error) ->
            ( model
            , Cmd.none
            , Just <| AppMsg.Error <| error
            )

        {-
           USERNAME MANAGEMENT
        -}
        ChangeUsernameFormInput input ->
            ( { model | username = Form.input input model.username }
            , Cmd.none
            , Nothing
            )

        ChangeUsername username ->
            let
                user =
                    auth.user
            in
                ( { model | username = Form.setStatus Form.Sending model.username }
                , Api.updateUser auth { user | username = username }
                    |> Task.attempt (lift << ChangeUsernameResult)
                , Nothing
                )

        ChangeUsernameResult (Ok user) ->
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

        ChangeUsernameResult (Err error) ->
            Helpers.extractFeedback error model [ ( "username", "global" ) ] <|
                \feedback ->
                    ( { model | username = Form.fail feedback model.username }
                    , Cmd.none
                    , Nothing
                    )

        {-
           EMAIL MANAGEMENT
        -}
        VerifyEmail email ->
            let
                user =
                    auth.user

                emails =
                    -- Set e.transacting to True on our email
                    List.map (\e -> { e | transacting = e.id == email.id }) user.emails
            in
                ( Helpers.updateUser model { user | emails = emails }
                , Api.verifyEmail auth email
                    |> Task.attempt (lift << VerifyEmailResult email)
                , Nothing
                )

        VerifyEmailResult email (Ok ()) ->
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

        VerifyEmailResult _ (Err error) ->
            ( model
            , Cmd.none
            , Just <| AppMsg.Error <| error
            )

        ConfirmEmailResult (Ok user) ->
            -- TODO popup notification
            ( Helpers.updateUser model user
            , Cmd.none
            , Just <| AppMsg.NavigateTo <| Router.Profile Router.Emails
            )

        ConfirmEmailResult (Err error) ->
            -- TODO popup notification
            Helpers.extractFeedback error model [ ( "detail", "global" ) ] <|
                \_ ->
                    ( { model | emailConfirmation = Model.ConfirmationFail }
                    , Cmd.none
                    , Nothing
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
                , Api.updateEmail auth { email | primary = True }
                    |> Task.attempt (lift << PrimaryEmailResult)
                , Nothing
                )

        PrimaryEmailResult (Ok user) ->
            ( Helpers.updateUser model user
            , Cmd.none
            , Nothing
            )

        PrimaryEmailResult (Err error) ->
            ( model
            , Cmd.none
            , Just <| AppMsg.Error <| error
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
                            , Api.updateEmail auth { secondaryEmail | primary = True }
                            )

                        _ ->
                            ( List.map
                                (\e -> { e | transacting = (e.id == email.id) })
                                user.emails
                            , Task.succeed user
                            )
            in
                ( Helpers.updateUser model { user | emails = emails }
                , fixPrimary
                    |> Task.andThen (always <| Api.deleteEmail auth email)
                    |> Task.attempt (lift << DeleteEmailResult)
                , Nothing
                )

        DeleteEmailResult (Ok user) ->
            -- TODO popup notification
            ( Helpers.updateUser model user
            , Cmd.none
            , Nothing
            )

        DeleteEmailResult (Err error) ->
            ( model
            , Cmd.none
            , Just <| AppMsg.Error <| error
            )

        AddEmailFormInput input ->
            ( { model | emails = Form.input input model.emails }
            , Cmd.none
            , Nothing
            )

        AddEmail input ->
            ( { model | emails = Form.setStatus Form.Sending model.emails }
            , Api.addEmail auth input |> Task.attempt (lift << AddEmailResult)
            , Nothing
            )

        AddEmailResult (Ok user) ->
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

        AddEmailResult (Err error) ->
            Helpers.extractFeedback error model [ ( "email", "global" ) ] <|
                \feedback ->
                    ( { model | emails = Form.fail feedback model.emails }
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
                , Api.postQuestionnaire auth processedInput
                    |> Task.attempt (lift << QuestionnaireFormResult)
                , Nothing
                )

        QuestionnaireFormResult (Ok profile) ->
            -- TODO: popup notification
            ( Helpers.updateProfile model profile
            , Cmd.none
            , Just <| AppMsg.NavigateTo <| Router.Profile Router.Dashboard
            )

        QuestionnaireFormResult (Err error) ->
            Helpers.extractFeedback error
                model
                [ ( "age", "age" )
                , ( "gender", "gender" )
                , ( "informed_how", "informedHow" )
                , ( "informed_what", "informedWhat" )
                , ( "job_type", "jobType" )
                , ( "job_freetext", "jobFreetext" )
                ]
            <|
                \feedback ->
                    ( { model | questionnaire = Form.fail feedback model.questionnaire }
                    , Cmd.none
                    , Nothing
                    )
