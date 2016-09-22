module Update exposing (update)

import Api
import Helpers
import LocalStorage
import Maybe.Extra exposing ((?))
import Model exposing (Model)
import Msg exposing (Msg(..))
import Navigation
import Router
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

        GotToken token ->
            Helpers.withAuth
                Types.Authenticating
                model
                ! [ Api.getUser token, LocalStorage.tokenSet token ]

        GotLocalToken maybeToken ->
            case maybeToken of
                Just token ->
                    Helpers.withAuth
                        Types.Authenticating
                        model
                        ! [ Api.getUser token ]

                Nothing ->
                    Helpers.withAuth Types.Anonymous model ! []

        GotUser token user ->
            let
                next =
                    case model.route of
                        Router.Login maybeNext ->
                            maybeNext ? Router.Home

                        _ ->
                            model.route
            in
                model
                    |> Helpers.withAuth (Types.Authenticated token user)
                    |> update (NavigateTo next)

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
            model
                |> Helpers.withAuth Types.Anonymous
                |> update (NavigateTo Router.Home)

        LogoutFail error ->
            let
                _ =
                    Debug.log "error logging user out" error
            in
                update LogoutSuccess model

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
                        |> Helpers.withStatus Model.Form
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
