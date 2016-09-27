module Update exposing (update)

import Api
import Cmds
import Helpers exposing ((!!))
import LocalStorage
import Maybe.Extra exposing ((?))
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
                authRoute =
                    Router.authRedirect model.auth route
            in
                Model.emptyForms { model | route = authRoute }
                    ! ((Navigation.newUrl (Router.toUrl authRoute))
                        :: Cmds.cmdsForRoute model authRoute
                      )

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
                        |> Helpers.withFeedback Types.emptyFeedback
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
                (\feedback ->
                    let
                        loginModel =
                            model.loginModel
                                |> Helpers.withStatus Model.Entering
                                |> Helpers.withFeedback feedback
                    in
                        { model | loginModel = loginModel }
                            ! []
                )

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
                    model ! [ Api.fetchAuth token |> Task.perform LoginLocalTokenFail LoginSuccess ]

                Nothing ->
                    updateAuth Types.Anonymous model

        LoginLocalTokenFail _ ->
            updateAuth Types.Anonymous model !! [ LocalStorage.tokenClear ]

        {-
           LOGOUT
        -}
        Logout ->
            authenticatedOrIgnore model <|
                (\auth ->
                    updateAuth Types.Authenticating model
                        !! [ Api.logout auth |> Task.perform LogoutFail (always LogoutSuccess)
                           , LocalStorage.tokenClear
                           ]
                )

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
        ProlificFormInput input ->
            let
                prolificModel =
                    model.prolificModel
                        |> Helpers.withInput input
                        |> Helpers.withFeedback Types.emptyFeedback
            in
                { model | prolificModel = prolificModel } ! []

        Prolific prolificId ->
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
                                (Types.globalFeedback
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
                        |> Helpers.withFeedback Types.emptyFeedback
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
                (\feedback ->
                    let
                        recoverModel =
                            model.recoverModel
                                |> Helpers.withStatus (Model.Form Model.Entering)
                                |> Helpers.withFeedback feedback
                    in
                        { model | recoverModel = recoverModel } ! []
                )

        RecoverSuccess ->
            let
                recoverModel =
                    model.recoverModel
                        |> Helpers.withStatus Model.Sent
                        |> Helpers.withFeedback Types.emptyFeedback
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
                        |> Helpers.withFeedback Types.emptyFeedback
            in
                { model | resetModel = resetModel } ! []

        Reset credentials tokens ->
            let
                feedback =
                    Types.emptyFeedback
                        |> (Types.updateFeedback "password1"
                                (if String.length credentials.password1 < 6 then
                                    Just "Password must be at least 6 characters"
                                 else
                                    Nothing
                                )
                           )
                        |> (Types.updateFeedback "global"
                                (if credentials.password1 /= credentials.password2 then
                                    Just "The two passwords don't match"
                                 else
                                    Nothing
                                )
                           )
            in
                if feedback == Types.emptyFeedback then
                    { model
                        | resetModel =
                            Helpers.withStatus
                                (Model.Form Model.Sending)
                                model.resetModel
                    }
                        ! [ Api.reset credentials tokens |> Task.perform ResetFail (always ResetSuccess) ]
                else
                    update (ResetFail <| Types.ApiFeedback feedback) model

        ResetFail error ->
            feedbackOrUnrecoverable error model <|
                (\feedback ->
                    let
                        resetModel =
                            model.resetModel
                                |> Helpers.withStatus (Model.Form Model.Entering)
                                |> Helpers.withFeedback feedback
                    in
                        { model | resetModel = resetModel } ! []
                )

        ResetSuccess ->
            let
                resetModel =
                    model.resetModel
                        |> Helpers.withStatus Model.Sent
                        |> Helpers.withFeedback Types.emptyFeedback

                model' =
                    { model | resetModel = resetModel }
            in
                authenticatedOrIgnore model' (\_ -> update Logout model')

        {-
           REGISTRATION
        -}
        RegisterFormInput input ->
            let
                registerModel =
                    model.registerModel
                        |> Helpers.withInput input
                        |> Helpers.withFeedback Types.emptyFeedback
            in
                { model | registerModel = registerModel } ! []

        Register maybeProlific credentials ->
            let
                registerModel =
                    Helpers.withStatus Model.Sending model.registerModel
            in
                { model | registerModel = registerModel }
                    ! [ Api.register maybeProlific credentials |> Task.perform RegisterFail LoginSuccess ]

        RegisterFail error ->
            feedbackOrUnrecoverable error model <|
                (\feedback ->
                    let
                        registerModel =
                            model.registerModel
                                |> Helpers.withStatus Model.Entering
                                |> Helpers.withFeedback feedback
                    in
                        { model | registerModel = registerModel } ! []
                )

        {-
           EMAIL MANAGEMENT
        -}
        VerifyEmail email ->
            Debug.crash "todo"

        VerifyEmailSuccess ->
            -- TODO popup notification
            Debug.crash "todo"

        PrimaryEmail email ->
            Debug.crash "todo"

        DeleteEmail email ->
            Debug.crash "todo"

        EmailFormInput input ->
            let
                emailsModel =
                    model.emailsModel
                        |> Helpers.withInput input
                        |> Helpers.withFeedback Types.emptyFeedback
            in
                { model | emailsModel = emailsModel } ! []

        AddEmail input ->
            authenticatedOrIgnore model <|
                (\auth ->
                    let
                        emailsModel =
                            model.emailsModel
                                |> Helpers.withStatus Model.Sending
                    in
                        { model | emailsModel = emailsModel }
                            ! [ Api.addEmail input auth |> Task.perform AddEmailFail AddEmailSuccess ]
                )

        AddEmailFail error ->
            feedbackOrUnrecoverable error model <|
                (\feedback ->
                    let
                        emailsModel =
                            model.emailsModel
                                |> Helpers.withStatus Model.Entering
                                |> Helpers.withFeedback feedback
                    in
                        { model | emailsModel = emailsModel } ! []
                )

        AddEmailSuccess user ->
            -- TODO: popup notification + saved badge
            let
                emailsModel =
                    model.emailsModel
                        |> Helpers.withInput ""
                        |> Helpers.withStatus Model.Entering
            in
                Helpers.updateUser { model | emailsModel = emailsModel } user ! []



-- AUTH WITH ROUTING


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
    -> (Types.Feedback -> ( Model, Cmd Msg ))
    -> ( Model, Cmd Msg )
feedbackOrUnrecoverable error model feedbackFunc =
    case error of
        Types.Unrecoverable error' ->
            update (Error error) model

        Types.ApiFeedback feedback ->
            feedbackFunc feedback


authenticatedOrIgnore :
    Model
    -> (Types.Auth -> ( Model, Cmd Msg ))
    -> ( Model, Cmd Msg )
authenticatedOrIgnore model authFunc =
    case model.auth of
        Types.Authenticated auth ->
            authFunc auth

        _ ->
            model ! []
