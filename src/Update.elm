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
import Types


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (Debug.log "msg" msg) of
        NoOp ->
            model ! []

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
            update (NavigateTo Router.Error) { model | error = Just error }

        LoginFormInput input ->
            let
                loginModel =
                    model.loginModel
                        |> Helpers.withInput input
                        |> Helpers.withFeedback Types.emptyFeedback
            in
                { model | loginModel = loginModel } ! []

        Login credentials ->
            auth Types.Authenticating model !! [ Api.login credentials ]

        LoginFail feedback ->
            let
                loginModel =
                    Helpers.withFeedback feedback model.loginModel
            in
                auth Types.Anonymous { model | loginModel = loginModel }

        GotToken maybeProlific token ->
            model ! [ Api.getUser maybeProlific token, LocalStorage.tokenSet token ]

        GotLocalToken maybeToken ->
            case maybeToken of
                Just token ->
                    model ! [ Api.getUser Nothing token ]

                Nothing ->
                    auth Types.Anonymous model

        GotUser maybeProlific token user ->
            case user.profile of
                Just _ ->
                    case model.route of
                        Router.Login maybeNext ->
                            authNav (Types.Authenticated token user) (maybeNext ? Router.Home) model

                        _ ->
                            auth (Types.Authenticated token user) model

                Nothing ->
                    model ! [ Api.createProfile user maybeProlific token ]

        GetUserFail feedback ->
            let
                loginModel =
                    Helpers.withFeedback (Debug.log "error fetching user" feedback) model.loginModel
            in
                auth Types.Anonymous { model | loginModel = loginModel }
                    !! [ LocalStorage.tokenClear ]

        Logout token ->
            auth Types.Authenticating model !! [ Api.logout token, LocalStorage.tokenClear ]

        LogoutSuccess ->
            case model.route of
                Router.Reset _ _ ->
                    auth Types.Anonymous model

                _ ->
                    authNav Types.Anonymous Router.Home model

        LogoutFail error ->
            let
                _ =
                    Debug.log "error logging user out" error
            in
                update LogoutSuccess model

        ProlificFormInput input ->
            let
                prolificModel =
                    model.prolificModel
                        |> Helpers.withInput input
                        |> Helpers.withFeedback Types.emptyFeedback
            in
                { model | prolificModel = prolificModel } ! []

        ProlificFormSubmit input ->
            let
                regex =
                    Regex.regex "^[a-z0-9]+$"
            in
                if Regex.contains regex input then
                    update (NavigateTo <| Router.Register <| Just input) model
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

        Recover email ->
            let
                recoverModel =
                    Helpers.withStatus Model.Sending model.recoverModel
            in
                { model | recoverModel = recoverModel } ! [ Api.recover email ]

        RecoverFormInput input ->
            let
                recoverModel =
                    model.recoverModel
                        |> Helpers.withInput input
                        |> Helpers.withFeedback Types.emptyFeedback
            in
                { model | recoverModel = recoverModel } ! []

        RecoverFail feedback ->
            let
                recoverModel =
                    model.recoverModel
                        |> Helpers.withStatus Model.Entering
                        |> Helpers.withFeedback feedback
            in
                { model | recoverModel = recoverModel } ! []

        RecoverSuccess ->
            let
                recoverModel =
                    model.recoverModel
                        |> Helpers.withStatus Model.Sent
                        |> Helpers.withFeedback Types.emptyFeedback
            in
                { model | recoverModel = recoverModel } ! []

        Reset credentials uid token ->
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
                    { model | resetModel = Helpers.withStatus Model.Sending model.resetModel }
                        ! [ Api.reset credentials uid token ]
                else
                    update (ResetFail feedback) model

        ResetFormInput input ->
            let
                resetModel =
                    model.resetModel
                        |> Helpers.withInput input
                        |> Helpers.withFeedback Types.emptyFeedback
            in
                { model | resetModel = resetModel } ! []

        ResetFail feedback ->
            let
                resetModel =
                    model.resetModel
                        |> Helpers.withStatus Model.Entering
                        |> Helpers.withFeedback feedback
            in
                { model | resetModel = resetModel } ! []

        ResetSuccess ->
            let
                resetModel =
                    model.resetModel
                        |> Helpers.withStatus Model.Sent
                        |> Helpers.withFeedback Types.emptyFeedback

                model' =
                    { model | resetModel = resetModel }
            in
                case model.auth of
                    Types.Authenticated token _ ->
                        update (Logout token) model'

                    _ ->
                        model' ! []

        Register maybeProlific credentials ->
            auth Types.Authenticating model !! [ Api.register maybeProlific credentials ]

        RegisterFormInput input ->
            let
                registerModel =
                    model.registerModel
                        |> Helpers.withInput input
                        |> Helpers.withFeedback Types.emptyFeedback
            in
                { model | registerModel = registerModel } ! []

        RegisterFail feedback ->
            let
                registerModel =
                    Helpers.withFeedback feedback model.registerModel
            in
                auth Types.Anonymous { model | registerModel = registerModel }

        CreatedProfile token user profile ->
            update (GotUser Nothing token { user | profile = Just profile }) model

        VerifyEmail email ->
            Debug.crash "todo"

        VerifyEmailSent ->
            Debug.crash "todo"

        PrimaryEmail email ->
            Debug.crash "todo"

        PrimariedEmail ->
            Debug.crash "todo"

        DeleteEmail email ->
            Debug.crash "todo"

        DeletedEmail ->
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
            case model.auth of
                Types.Authenticated token _ ->
                    let
                        emailsModel =
                            model.emailsModel
                                |> Helpers.withStatus Model.Sending
                    in
                        { model | emailsModel = emailsModel }
                            ! [ Api.addEmail input token ]

                _ ->
                    model ! []

        AddEmailFail feedback ->
            let
                emailsModel =
                    model.emailsModel
                        |> Helpers.withStatus Model.Entering
                        |> Helpers.withFeedback feedback
            in
                { model | emailsModel = emailsModel } ! []



-- AUTH WITH ROUTING


auth : Types.Auth -> Model -> ( Model, Cmd Msg )
auth auth' model =
    update (NavigateTo model.route) { model | auth = auth' }


authNav : Types.Auth -> Router.Route -> Model -> ( Model, Cmd Msg )
authNav auth' route model =
    auth auth' { model | route = route }
