module Update exposing (update)

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

        Login { username, password } ->
            model ! []
