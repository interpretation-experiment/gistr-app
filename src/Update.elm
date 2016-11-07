module Update exposing (update)

import Api
import Auth.Msg as AuthMsg
import Auth.Update as AuthUpdate
import Experiment
import Experiment.Reformulation as Reformulation
import Feedback
import Form
import Helpers exposing ((!!))
import Instructions
import List.Nonempty as Nonempty
import LocalStorage
import Maybe.Extra exposing ((?), or)
import Model exposing (Model)
import Msg exposing (Msg(..))
import Navigation
import Regex
import Router
import Store
import String
import Strings
import Task
import Types
import Validate


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Animate _ ->
            doUpdate msg model

        _ ->
            let
                _ =
                    Debug.log "msg" msg
            in
                doUpdate msg model


doUpdate : Msg -> Model -> ( Model, Cmd Msg )
doUpdate msg model =
    case msg of
        NoOp ->
            model ! []

        Animate msg ->
            { model
                | password = Form.animate msg model.password
                , username = Form.animate msg model.username
                , emails = Form.animate msg model.emails
            }
                ! []

        {-
           NAVIGATION
        -}
        NavigateTo route ->
            let
                ( model', cmd ) =
                    Helpers.navigateTo model route
            in
                model' ! [ cmd, Navigation.newUrl (Router.toUrl model'.route) ]

        Error error ->
            -- Don't use `udpate (NavigateTo ...)` here so as not to lose the form inputs
            { model | route = Router.Error, error = Just error }
                ! [ Navigation.newUrl (Router.toUrl Router.Error) ]

        {-
           AUTH
        -}
        AuthMsg msg ->
            AuthUpdate.update AuthMsg msg model
                |> processMaybeMsg

        {-
           PASSWORD RECOVERY
        -}
        RecoverFormInput input ->
            case model.recover of
                Model.Form form ->
                    { model | recover = Model.Form (Form.input input form) } ! []

                Model.Sent _ ->
                    model ! []

        RecoverFail error ->
            feedbackOrUnrecoverable error model <|
                \feedback ->
                    case model.recover of
                        Model.Form form ->
                            { model | recover = Model.Form (Form.fail feedback form) } ! []

                        Model.Sent _ ->
                            model ! []

        Recover email ->
            case model.recover of
                Model.Form form ->
                    { model | recover = Model.Form (Form.setStatus Form.Sending form) }
                        ! [ Api.recover email
                                |> Task.perform RecoverFail (always <| RecoverSuccess email)
                          ]

                Model.Sent _ ->
                    model ! []

        RecoverSuccess email ->
            { model | recover = Model.Sent email } ! []

        {-
           PASSWORD RESET
        -}
        ResetFormInput input ->
            case model.reset of
                Model.Form form ->
                    { model | reset = Model.Form (Form.input input form) } ! []

                Model.Sent _ ->
                    model ! []

        ResetFail error ->
            feedbackOrUnrecoverable error model <|
                \feedback ->
                    case model.reset of
                        Model.Form form ->
                            { model | reset = Model.Form (Form.fail feedback form) } ! []

                        Model.Sent _ ->
                            model ! []

        Reset credentials tokens ->
            case model.reset of
                Model.Form form ->
                    let
                        feedback =
                            [ .password1 >> Helpers.ifShorterThan 6 ( "password1", Strings.passwordTooShort )
                            , Validate.ifInvalid
                                (\c -> c.password1 /= c.password2)
                                ( "global", Strings.passwordsDontMatch )
                            ]
                                |> Validate.all
                                |> Feedback.fromValidator credentials
                    in
                        if Feedback.isEmpty feedback then
                            { model | reset = Model.Form (Form.setStatus Form.Sending form) }
                                ! [ Api.reset credentials tokens
                                        |> Task.perform ResetFail (always ResetSuccess)
                                  ]
                        else
                            update (ResetFail <| Types.ApiFeedback feedback) model

                Model.Sent _ ->
                    model ! []

        ResetSuccess ->
            update (AuthMsg AuthMsg.Logout) { model | reset = Model.Sent () }

        {-
           REGISTRATION
        -}
        RegisterFormInput input ->
            { model | register = Form.input input model.register } ! []

        RegisterFail error ->
            feedbackOrUnrecoverable error model <|
                \feedback ->
                    { model | register = Form.fail feedback model.register } ! []

        Register maybeProlific credentials ->
            { model | register = Form.setStatus Form.Sending model.register }
                ! [ Api.register maybeProlific credentials
                        |> Task.perform RegisterFail (AuthMsg << AuthMsg.LoginSuccess)
                  ]

        {-
           PASSWORD MANAGEMENT
        -}
        ChangePasswordFormInput input ->
            { model | password = Form.input input model.password } ! []

        ChangePasswordFail error ->
            feedbackOrUnrecoverable error model <|
                \feedback ->
                    { model | password = Form.fail feedback model.password } ! []

        ChangePassword credentials ->
            Helpers.authenticatedOrIgnore model <|
                \auth ->
                    { model | password = Form.setStatus Form.Sending model.password }
                        ! [ Api.changePassword credentials auth
                                |> Task.perform ChangePasswordFail ChangePasswordSuccess
                          ]

        ChangePasswordSuccess auth ->
            let
                emptyInput =
                    Types.PasswordCredentials "" "" ""

                feedback =
                    Feedback.globalSuccess model.password.feedback
            in
                update
                    (AuthMsg <| AuthMsg.LoginSuccess auth)
                    { model | password = Form.succeed emptyInput feedback model.password }

        ChangePasswordRecover ->
            Helpers.authenticatedOrIgnore model <|
                \auth ->
                    let
                        maybePrimary =
                            List.filter (\e -> e.primary) auth.user.emails |> List.head

                        maybeRecovery =
                            maybePrimary `or` (List.head auth.user.emails)
                    in
                        case maybeRecovery of
                            Nothing ->
                                -- TODO popup notification
                                model ! []

                            Just email ->
                                -- TODO popup notification
                                model
                                    ! [ Api.recover email.email
                                            |> Task.perform Error
                                                (always ChangePasswordRecoverSuccess)
                                      ]

        ChangePasswordRecoverSuccess ->
            -- TODO popup notification
            model ! []

        {-
           USERNAME MANAGEMENT
        -}
        ChangeUsernameFormInput input ->
            { model | username = Form.input input model.username } ! []

        ChangeUsernameFail error ->
            feedbackOrUnrecoverable error model <|
                \feedback ->
                    { model | username = Form.fail feedback model.username } ! []

        ChangeUsername username ->
            Helpers.authenticatedOrIgnore model <|
                \auth ->
                    let
                        user =
                            auth.user
                    in
                        { model | username = Form.setStatus Form.Sending model.username }
                            ! [ Api.updateUser { user | username = username } auth
                                    |> Task.perform ChangeUsernameFail ChangeUsernameSuccess
                              ]

        ChangeUsernameSuccess user ->
            let
                feedback =
                    Feedback.globalSuccess model.username.feedback
            in
                Helpers.updateUser
                    { model | username = Form.succeed "" feedback model.username }
                    user
                    ! []

        {-
           EMAIL MANAGEMENT
        -}
        RequestEmailVerification email ->
            Helpers.authenticatedOrIgnore model <|
                \auth ->
                    let
                        user =
                            auth.user

                        emails =
                            -- Set e.transacting to True on our email
                            List.map (\e -> { e | transacting = e.id == email.id }) user.emails
                    in
                        Helpers.updateUser model { user | emails = emails }
                            ! [ Api.requestEmailVerification email auth
                                    |> Task.perform Error
                                        (always <| RequestEmailVerificationSuccess email)
                              ]

        RequestEmailVerificationSuccess email ->
            -- TODO popup notification
            Helpers.authenticatedOrIgnore model <|
                \auth ->
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
                        Helpers.updateUser model { user | emails = emails } ! []

        EmailConfirmationFail error ->
            -- TODO popup notification
            feedbackOrUnrecoverable error model <|
                \_ ->
                    { model | emailConfirmation = Model.ConfirmationFail } ! []

        EmailConfirmationSuccess user ->
            -- TODO popup notification
            Helpers.authenticatedOrIgnore model <|
                \auth ->
                    update
                        (NavigateTo <| Router.Profile Router.Emails)
                        (Helpers.updateUser model user)

        PrimaryEmail email ->
            Helpers.authenticatedOrIgnore model <|
                \auth ->
                    let
                        user =
                            auth.user

                        emails =
                            -- Set e.primary to True on our email and possibly on the other
                            -- primary email, and set e.transacting on all emails
                            List.map (\e -> { e | transacting = True }) user.emails
                    in
                        Helpers.updateUser model { user | emails = emails }
                            ! [ Api.updateEmail { email | primary = True } auth
                                    |> Task.perform Error PrimaryEmailSuccess
                              ]

        PrimaryEmailSuccess user ->
            Helpers.authenticatedOrIgnore model <|
                \auth -> Helpers.updateUser model user ! []

        DeleteEmail email ->
            Helpers.authenticatedOrIgnore model <|
                \auth ->
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
                        Helpers.updateUser model { user | emails = emails }
                            ! [ Task.andThen fixPrimary (always <| Api.deleteEmail email auth)
                                    |> Task.perform Error DeleteEmailSuccess
                              ]

        DeleteEmailSuccess user ->
            -- TODO popup notification
            Helpers.authenticatedOrIgnore model <|
                \auth -> Helpers.updateUser model user ! []

        AddEmailFormInput input ->
            { model | emails = Form.input input model.emails } ! []

        AddEmailFail error ->
            feedbackOrUnrecoverable error model <|
                \feedback ->
                    { model | emails = Form.fail feedback model.emails } ! []

        AddEmail input ->
            Helpers.authenticatedOrIgnore model <|
                \auth ->
                    { model | emails = Form.setStatus Form.Sending model.emails }
                        ! [ Api.addEmail input auth
                                |> Task.perform AddEmailFail AddEmailSuccess
                          ]

        AddEmailSuccess user ->
            -- TODO: popup notification
            let
                feedback =
                    Feedback.globalSuccess model.emails.feedback
            in
                Helpers.updateUser
                    { model | emails = Form.succeed "" feedback model.emails }
                    user
                    ! []

        {-
           QUESTIONNAIRE
        -}
        QuestionnaireFormInput input ->
            { model | questionnaire = Form.input input model.questionnaire } ! []

        QuestionnaireFormConfirm input ->
            let
                informedValidator =
                    [ .informedHow >> Helpers.ifShorterThan 5 ( "informedHow", Strings.fiveCharactersPlease )
                    , .informedWhat >> Helpers.ifShorterThan 5 ( "informedWhat", Strings.fiveCharactersPlease )
                    ]
                        |> Validate.all

                feedback =
                    [ .age >> Validate.ifNotInt ( "age", Strings.intPlease )
                    , .gender >> Validate.ifBlank ( "gender", Strings.genderPlease )
                    , Helpers.ifThenValidate .informed informedValidator
                    , .jobType >> Validate.ifBlank ( "jobType", Strings.jobTypePlease )
                    , .jobFreetext >> Helpers.ifShorterThan 5 ( "jobFreetext", Strings.fiveCharactersPlease )
                    ]
                        |> Validate.all
                        |> Feedback.fromValidator input
            in
                if Feedback.isEmpty feedback then
                    { model | questionnaire = Form.confirm input model.questionnaire } ! []
                else
                    { model | questionnaire = Form.fail feedback model.questionnaire } ! []

        QuestionnaireFormCorrect ->
            { model | questionnaire = Form.setStatus Form.Entering model.questionnaire } ! []

        QuestionnaireFormSubmit input ->
            Helpers.authenticatedOrIgnore model <|
                \auth ->
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
                        { model | questionnaire = Form.setStatus Form.Sending model.questionnaire }
                            ! [ Api.postQuestionnaire processedInput auth
                                    |> Task.perform QuestionnaireFormFail QuestionnaireFormSuccess
                              ]

        QuestionnaireFormFail error ->
            feedbackOrUnrecoverable error model <|
                \feedback ->
                    { model | questionnaire = Form.fail feedback model.questionnaire } ! []

        QuestionnaireFormSuccess user ->
            -- TODO: popup notification
            update
                (NavigateTo <| Router.Profile Router.Dashboard)
                (Helpers.updateUser model user)

        {-
           STORE
        -}
        GotStoreItem item ->
            { model | store = Store.set item model.store } ! []

        GotMeta meta ->
            let
                store =
                    model.store
            in
                { model | store = { store | meta = Just meta } } ! []

        {-
           REFORMULATIONS EXPERIMENT
        -}
        ReformulationInstructions msg ->
            case model.experiment of
                Experiment.Instructions state ->
                    let
                        ( newState, maybeOut ) =
                            Instructions.update
                                Reformulation.instructionsUpdateConfig
                                msg
                                state

                        newModel =
                            { model | experiment = Experiment.Instructions newState }
                    in
                        case maybeOut of
                            Nothing ->
                                newModel ! []

                            Just outMsg ->
                                update outMsg newModel

                _ ->
                    model ! []

        ReformulationInstructionsRestart ->
            { model
                | experiment =
                    Experiment.Instructions
                        (Instructions.start Reformulation.instructionsOrder)
            }
                ! []

        ReformulationInstructionsQuit index ->
            if index + 1 == Nonempty.length Reformulation.instructionsOrder then
                update ReformulationInstructionsDone model
            else
                { model | experiment = Experiment.Instructions Instructions.hide } ! []

        ReformulationInstructionsDone ->
            -- TODO: set intro read
            { model | experiment = Experiment.Instructions Instructions.hide } ! []

        ReformulationExpStart ->
            -- TODO: if trained, do exp directly, if not, do training
            { model
                | experiment =
                    Experiment.Training
                        (Reformulation.Trial () Reformulation.Reading)
            }
                ! []



-- UPDATE HELPERS


processMaybeMsg : ( Model, Cmd Msg, Maybe Msg ) -> ( Model, Cmd Msg )
processMaybeMsg ( model, cmd, maybeMsg ) =
    case maybeMsg of
        Nothing ->
            ( model, cmd )

        Just msg ->
            update msg model !! [ cmd ]


feedbackOrUnrecoverable :
    Types.Error
    -> Model
    -> (Feedback.Feedback -> ( Model, Cmd Msg ))
    -> ( Model, Cmd Msg )
feedbackOrUnrecoverable error model feedbackFunc =
    case error of
        Types.Unrecoverable _ ->
            update (Error error) model

        Types.ApiFeedback feedback ->
            feedbackFunc feedback
