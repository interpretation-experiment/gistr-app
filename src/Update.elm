module Update exposing (update)

import Api
import Helpers
import Model exposing (Model)
import Msg exposing (Msg(..))
import Navigation
import Router
import Types


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (Debug.log "msg" msg) of
        NavigateTo route ->
            model
                ! if model.route /= route then
                    [ Navigation.newUrl (Router.toUrl route) ]
                  else
                    []

        LoginFormUsername username ->
            let
                loginModel =
                    model.loginModel

                input =
                    { username = username
                    , password = loginModel.input.password
                    }

                newLoginModel =
                    { loginModel | input = input }
            in
                { model | loginModel = newLoginModel } ! []

        LoginFormPassword password ->
            let
                loginModel =
                    model.loginModel

                input =
                    { username = loginModel.input.username
                    , password = password
                    }

                newLoginModel =
                    { loginModel | input = input }
            in
                { model | loginModel = newLoginModel } ! []

        Login credentials ->
            { model | auth = Types.Authenticating } ! [ Api.login credentials ]

        LoginTokenSuccess token ->
            { model | auth = Types.Authenticating } ! [ Api.loginUser token ]

        -- DO: set localToken
        LoginTokenFail feedback ->
            let
                loginModel =
                    model.loginModel

                newLoginModel =
                    { loginModel | feedback = feedback }
            in
                { model | auth = Types.Anonymous, loginModel = newLoginModel } ! []

        LoginUserSuccess token user ->
            Model.emptyForms { model | auth = Types.Authenticated token user }
                ! [ Helpers.cmd (NavigateTo Router.Home) ]

        LoginUserFail error ->
            let
                _ =
                    Debug.log "error fetching user" error
            in
                Model.emptyForms { model | auth = Types.Anonymous } ! []

        Logout ->
            case model.auth of
                Types.Authenticated token _ ->
                    { model | auth = Types.Authenticating } ! [ Api.logout token ]

                -- DO: clear localToken
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
                Model.emptyForms { model | auth = Types.Anonymous }
                    ! [ Helpers.cmd (NavigateTo Router.Home) ]
