module Update exposing (update)

import Api
import Helpers
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
                    ! [ Navigation.newUrl (Router.toUrl authRoute) ]

        LoginFormUsername username ->
            let
                input =
                    model.loginModel.input

                newInput =
                    { input | username = username }

                loginModel =
                    model.loginModel
                        |> Helpers.withInput newInput
                        |> Helpers.withFeedback Types.emptyFeedback
            in
                { model | loginModel = loginModel } ! []

        LoginFormPassword password ->
            let
                input =
                    model.loginModel.input

                newInput =
                    { input | password = password }

                loginModel =
                    model.loginModel
                        |> Helpers.withInput newInput
                        |> Helpers.withFeedback Types.emptyFeedback
            in
                { model | loginModel = loginModel } ! []

        Login credentials ->
            Helpers.withAuth
                Types.Authenticating
                model
                ! [ Api.login credentials ]

        LoginFail feedback ->
            let
                loginModel =
                    model.loginModel
                        |> Helpers.withFeedback feedback
            in
                Helpers.withAuth
                    Types.Anonymous
                    { model | loginModel = loginModel }
                    ! []

        GotToken maybeProlific token ->
            Helpers.withAuth
                Types.Authenticating
                model
                ! [ Api.getUser maybeProlific token
                  , LocalStorage.tokenSet token
                  ]

        GotLocalToken maybeToken ->
            case maybeToken of
                Just token ->
                    Helpers.withAuth
                        Types.Authenticating
                        model
                        ! [ Api.getUser Nothing token ]

                Nothing ->
                    Helpers.withAuth Types.Anonymous model ! []

        GotUser maybeProlific token user ->
            -- TODO: if the user has no profile, initiate creation (and keep status authenticating)
            let
                model' =
                    model
                        |> Helpers.withAuth (Types.Authenticated token user)
            in
                case model.route of
                    Router.Login maybeNext ->
                        update (NavigateTo (maybeNext ? Router.Home)) model'

                    _ ->
                        model' ! []

        GetUserFail feedback ->
            let
                loginModel =
                    model.loginModel
                        |> Helpers.withFeedback (Debug.log "error fetching user" feedback)
            in
                Helpers.withAuth
                    Types.Anonymous
                    { model | loginModel = loginModel }
                    ! [ LocalStorage.tokenClear ]

        Logout ->
            case model.auth of
                Types.Authenticated token _ ->
                    Helpers.withAuth Types.Authenticating model
                        ! [ Api.logout token, LocalStorage.tokenClear ]

                -- Ignore any other status (there's no one to log out)
                _ ->
                    model ! []

        LogoutSuccess ->
            let
                model' =
                    model
                        |> Helpers.withAuth Types.Anonymous
            in
                case model.route of
                    Router.Reset _ _ ->
                        model' ! []

                    _ ->
                        update (NavigateTo Router.Home) model'

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
                    model.recoverModel
                        |> Helpers.withStatus Model.Sending
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
                                    (Just "Password must be at least 6 characters")
                                 else
                                    Nothing
                                )
                           )
                        |> (Types.updateFeedback "global"
                                (if credentials.password1 /= credentials.password2 then
                                    (Just "The two passwords don't match")
                                 else
                                    Nothing
                                )
                           )
            in
                if feedback == Types.emptyFeedback then
                    { model
                        | resetModel =
                            model.resetModel
                                |> Helpers.withStatus Model.Sending
                    }
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
            in
                update Logout { model | resetModel = resetModel }

        Register maybeProlific credentials ->
            Helpers.withAuth Types.Authenticating model
                ! [ Api.register maybeProlific credentials ]

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
                    model.registerModel
                        |> Helpers.withFeedback feedback
            in
                Helpers.withAuth
                    Types.Anonymous
                    { model | registerModel = registerModel }
                    ! []
