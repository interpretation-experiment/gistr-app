module Update exposing (update)

import Api
import Helpers
import Model exposing (Model)
import Msg exposing (Msg(..))
import Navigation
import Router
import LocalStorage
import Types


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (Debug.log "msg" msg) of
        NoOp ->
            model ! []

        NavigateTo route ->
            model
                ! if model.route /= route then
                    [ Navigation.newUrl (Router.toUrl route) ]
                  else
                    []

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
            { model | auth = Types.Authenticating } ! [ Api.login credentials ]

        LoginFail feedback ->
            let
                loginModel =
                    model.loginModel
                        |> Helpers.withFeedback feedback
            in
                { model | auth = Types.Anonymous, loginModel = loginModel } ! []

        GotToken token ->
            { model | auth = Types.Authenticating }
                ! [ Api.getUser token, LocalStorage.tokenSet token ]

        GotLocalToken maybeToken ->
            case maybeToken of
                Just token ->
                    { model | auth = Types.Authenticating } ! [ Api.getUser token ]

                Nothing ->
                    { model | auth = Types.Anonymous } ! []

        GotUser token user ->
            let
                next =
                    case model.route of
                        Router.Login (Just next) ->
                            next

                        _ ->
                            Router.Home
            in
                Model.emptyForms { model | auth = Types.Authenticated token user }
                    ! [ Helpers.cmd (NavigateTo next) ]

        GetUserFail error ->
            let
                _ =
                    Debug.log "error fetching user" error
            in
                Model.emptyForms { model | auth = Types.Anonymous }
                    ! [ LocalStorage.tokenClear ]

        Logout ->
            case model.auth of
                Types.Authenticated token _ ->
                    { model | auth = Types.Authenticating }
                        ! [ Api.logout token, LocalStorage.tokenClear ]

                -- Ignore any other status (there's no one to log out)
                _ ->
                    model ! []

        LogoutSuccess ->
            Model.emptyForms { model | auth = Types.Anonymous }
                ! [ Helpers.cmd (NavigateTo Router.Home) ]

        LogoutFail error ->
            let
                _ =
                    Debug.log "error logging user out" error
            in
                model ! [ Helpers.cmd LogoutSuccess ]

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
