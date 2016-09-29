module Update exposing (update)

import Api
import Feedback
import Helpers exposing ((!!))
import LocalStorage
import Maybe.Extra exposing ((?), or)
import Model exposing (Model)
import Msg exposing (Msg(..))
import Navigation
import Regex
import Router
import String
import Task
import Types


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (Debug.log "msg" msg) of
        NoOp ->
            model ! []

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
           LOGIN
        -}
        LoginFormInput input ->
            let
                loginModel =
                    model.loginModel
                        |> Helpers.withInput input
                        |> Helpers.withFeedback Feedback.empty
            in
                { model | loginModel = loginModel } ! []

        Login credentials ->
            let
                loginModel =
                    Helpers.withStatus Model.Sending model.loginModel
            in
                { model | loginModel = loginModel }
                    ! [ Api.login credentials
                            |> Task.perform LoginFail LoginSuccess
                      ]

        LoginFail error ->
            feedbackOrUnrecoverable error model <|
                \feedback ->
                    let
                        loginModel =
                            model.loginModel
                                |> Helpers.withStatus Model.Entering
                                |> Helpers.withFeedback feedback
                    in
                        { model | loginModel = loginModel }
                            ! []

        LoginSuccess auth ->
            (case model.route of
                Router.Login maybeNext ->
                    updateAuthNav (Types.Authenticated auth) (maybeNext ? Router.Home) model

                _ ->
                    updateAuth (Types.Authenticated auth) model
            )
                !! [ LocalStorage.tokenSet auth.token ]

        {-
           LOCAL TOKEN LOGIN
        -}
        GotLocalToken maybeToken ->
            case maybeToken of
                Just token ->
                    model
                        ! [ Api.fetchAuth token |> Task.perform LoginLocalTokenFail LoginSuccess ]

                Nothing ->
                    updateAuth Types.Anonymous model

        LoginLocalTokenFail _ ->
            updateAuth Types.Anonymous model !! [ LocalStorage.tokenClear ]

        {-
           LOGOUT
        -}
        Logout ->
            Helpers.authenticatedOrIgnore model <|
                \auth ->
                    updateAuth Types.Authenticating model
                        !! [ Api.logout auth |> Task.perform LogoutFail (always LogoutSuccess)
                           , LocalStorage.tokenClear
                           ]

        LogoutFail error ->
            let
                _ =
                    Debug.log "error logging user out" (toString error)
            in
                update LogoutSuccess model

        LogoutSuccess ->
            case model.route of
                Router.Reset _ ->
                    updateAuth Types.Anonymous model

                _ ->
                    updateAuthNav Types.Anonymous Router.Home model

        {-
           PROLIFIC
        -}
        SetProlificFormInput input ->
            let
                prolificModel =
                    model.prolificModel
                        |> Helpers.withInput input
                        |> Helpers.withFeedback Feedback.empty
            in
                { model | prolificModel = prolificModel } ! []

        SetProlific prolificId ->
            let
                regex =
                    Regex.regex "^[a-z0-9]+$"
            in
                if Regex.contains regex prolificId then
                    update (NavigateTo <| Router.Register <| Just prolificId) model
                else
                    { model
                        | prolificModel =
                            Helpers.withFeedback
                                (Feedback.globalError
                                    ("This is not a valid "
                                        ++ "Prolific Academic ID "
                                    )
                                )
                                model.prolificModel
                    }
                        ! []

        {-
           PASSWORD RECOVERY
        -}
        RecoverFormInput input ->
            let
                recoverModel =
                    model.recoverModel
                        |> Helpers.withInput input
                        |> Helpers.withFeedback Feedback.empty
            in
                { model | recoverModel = recoverModel } ! []

        Recover email ->
            let
                recoverModel =
                    Helpers.withStatus (Model.Form Model.Sending) model.recoverModel
            in
                { model | recoverModel = recoverModel }
                    ! [ Api.recover email |> Task.perform RecoverFail (always RecoverSuccess) ]

        RecoverFail error ->
            feedbackOrUnrecoverable error model <|
                \feedback ->
                    let
                        recoverModel =
                            model.recoverModel
                                |> Helpers.withStatus (Model.Form Model.Entering)
                                |> Helpers.withFeedback feedback
                    in
                        { model | recoverModel = recoverModel } ! []

        RecoverSuccess ->
            let
                recoverModel =
                    model.recoverModel
                        |> Helpers.withStatus Model.Sent
                        |> Helpers.withFeedback Feedback.empty
            in
                { model | recoverModel = recoverModel } ! []

        {-
           PASSWORD RESET
        -}
        ResetFormInput input ->
            let
                resetModel =
                    model.resetModel
                        |> Helpers.withInput input
                        |> Helpers.withFeedback Feedback.empty
            in
                { model | resetModel = resetModel } ! []

        Reset credentials tokens ->
            let
                feedback =
                    Feedback.empty
                        |> (Feedback.updateError "password1"
                                (if String.length credentials.password1 < 6 then
                                    Just "Password must be at least 6 characters"
                                 else
                                    Nothing
                                )
                           )
                        |> (Feedback.updateError "global"
                                (if credentials.password1 /= credentials.password2 then
                                    Just "The two passwords don't match"
                                 else
                                    Nothing
                                )
                           )
            in
                if feedback == Feedback.empty then
                    { model
                        | resetModel =
                            Helpers.withStatus
                                (Model.Form Model.Sending)
                                model.resetModel
                    }
                        ! [ Api.reset credentials tokens
                                |> Task.perform ResetFail (always ResetSuccess)
                          ]
                else
                    update (ResetFail <| Types.ApiFeedback feedback) model

        ResetFail error ->
            feedbackOrUnrecoverable error model <|
                \feedback ->
                    let
                        resetModel =
                            model.resetModel
                                |> Helpers.withStatus (Model.Form Model.Entering)
                                |> Helpers.withFeedback feedback
                    in
                        { model | resetModel = resetModel } ! []

        ResetSuccess ->
            let
                resetModel =
                    model.resetModel
                        |> Helpers.withStatus Model.Sent
                        |> Helpers.withFeedback Feedback.empty

                model' =
                    { model | resetModel = resetModel }
            in
                Helpers.authenticatedOrIgnore model' (\_ -> update Logout model')

        {-
           REGISTRATION
        -}
        RegisterFormInput input ->
            let
                registerModel =
                    model.registerModel
                        |> Helpers.withInput input
                        |> Helpers.withFeedback Feedback.empty
            in
                { model | registerModel = registerModel } ! []

        Register maybeProlific credentials ->
            let
                registerModel =
                    Helpers.withStatus Model.Sending model.registerModel
            in
                { model | registerModel = registerModel }
                    ! [ Api.register maybeProlific credentials
                            |> Task.perform RegisterFail LoginSuccess
                      ]

        RegisterFail error ->
            feedbackOrUnrecoverable error model <|
                \feedback ->
                    let
                        registerModel =
                            model.registerModel
                                |> Helpers.withStatus Model.Entering
                                |> Helpers.withFeedback feedback
                    in
                        { model | registerModel = registerModel } ! []

        {-
           PASSWORD MANAGEMENT
        -}
        ChangePasswordFormInput input ->
            let
                changePasswordModel =
                    model.changePasswordModel
                        |> Helpers.withInput input
                        |> Helpers.withFeedback Feedback.empty
            in
                { model | changePasswordModel = changePasswordModel } ! []

        ChangePassword credentials ->
            Helpers.authenticatedOrIgnore model <|
                \auth ->
                    let
                        changePasswordModel =
                            model.changePasswordModel
                                |> Helpers.withStatus Model.Sending
                    in
                        { model | changePasswordModel = changePasswordModel }
                            ! [ Api.changePassword credentials auth
                                    |> Task.perform ChangePasswordFail ChangePasswordSuccess
                              ]

        ChangePasswordFail error ->
            feedbackOrUnrecoverable error model <|
                \feedback ->
                    let
                        changePasswordModel =
                            model.changePasswordModel
                                |> Helpers.withStatus Model.Entering
                                |> Helpers.withFeedback feedback
                    in
                        { model | changePasswordModel = changePasswordModel } ! []

        ChangePasswordSuccess auth ->
            -- TODO saved badge
            update (LoginSuccess auth) model

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
            let
                changeUsernameModel =
                    model.changeUsernameModel
                        |> Helpers.withInput input
                        |> Helpers.withFeedback Feedback.empty
            in
                { model | changeUsernameModel = changeUsernameModel } ! []

        ChangeUsername username ->
            Helpers.authenticatedOrIgnore model <|
                \auth ->
                    let
                        user =
                            auth.user

                        changeUsernameModel =
                            model.changeUsernameModel
                                |> Helpers.withStatus Model.Sending
                    in
                        { model | changeUsernameModel = changeUsernameModel }
                            ! [ Api.updateUser { user | username = username } auth
                                    |> Task.perform ChangeUsernameFail ChangeUsernameSuccess
                              ]

        ChangeUsernameFail error ->
            feedbackOrUnrecoverable error model <|
                \feedback ->
                    let
                        changeUsernameModel =
                            model.changeUsernameModel
                                |> Helpers.withStatus Model.Entering
                                |> Helpers.withFeedback feedback
                    in
                        { model | changeUsernameModel = changeUsernameModel } ! []

        ChangeUsernameSuccess user ->
            -- TODO saved badge
            Helpers.updateUser (Model.emptyForms model) user ! []

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
                    { model | emailConfirmationModel = Model.ConfirmationFail } ! []

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
            let
                emailsModel =
                    model.emailsModel
                        |> Helpers.withInput input
                        |> Helpers.withFeedback Feedback.empty
            in
                { model | emailsModel = emailsModel } ! []

        AddEmail input ->
            Helpers.authenticatedOrIgnore model <|
                \auth ->
                    let
                        emailsModel =
                            model.emailsModel
                                |> Helpers.withStatus Model.Sending
                    in
                        { model | emailsModel = emailsModel }
                            ! [ Api.addEmail input auth
                                    |> Task.perform AddEmailFail AddEmailSuccess
                              ]

        AddEmailFail error ->
            feedbackOrUnrecoverable error model <|
                \feedback ->
                    let
                        emailsModel =
                            model.emailsModel
                                |> Helpers.withStatus Model.Entering
                                |> Helpers.withFeedback feedback
                    in
                        { model | emailsModel = emailsModel } ! []

        AddEmailSuccess user ->
            -- TODO: popup notification + saved badge
            Helpers.updateUser (Model.emptyForms model) user ! []



-- ROUTING WITH AUTH


updateAuth : Types.AuthStatus -> Model -> ( Model, Cmd Msg )
updateAuth authStatus model =
    update (NavigateTo model.route) { model | auth = authStatus }


updateAuthNav : Types.AuthStatus -> Router.Route -> Model -> ( Model, Cmd Msg )
updateAuthNav authStatus route model =
    updateAuth authStatus { model | route = route }



-- UPDATE HELPERS


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
