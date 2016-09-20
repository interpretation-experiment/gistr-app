module Update exposing (update)

import Api
import Helpers
import Model exposing (Model)
import Msg exposing (Msg(..))
import Navigation
import Router
import Subscriptions
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
            in
                { model | loginModel = Model.withInput newInput model.loginModel } ! []

        LoginFormPassword password ->
            let
                input =
                    model.loginModel.input

                newInput =
                    { input | password = password }
            in
                { model | loginModel = Model.withInput newInput model.loginModel } ! []

        Login credentials ->
            { model | auth = Types.Authenticating } ! [ Api.login credentials ]

        LoginFail feedback ->
            { model
                | auth = Types.Anonymous
                , loginModel = Model.withFeedback feedback model.loginModel
            }
                ! []

        GotToken token ->
            { model | auth = Types.Authenticating }
                ! [ Api.getUser token
                  , Subscriptions.localTokenSet token
                  ]

        GotLocalToken maybeToken ->
            case maybeToken of
                Just token ->
                    { model | auth = Types.Authenticating } ! [ Api.getUser token ]

                Nothing ->
                    { model | auth = Types.Anonymous } ! []

        GotUser token user ->
            Model.emptyForms { model | auth = Types.Authenticated token user }
                ! [ Helpers.cmd (NavigateTo Router.Home) ]

        GetUserFail error ->
            let
                _ =
                    Debug.log "error fetching user" error
            in
                Model.emptyForms { model | auth = Types.Anonymous }
                    ! [ Subscriptions.localTokenClear ]

        Logout ->
            case model.auth of
                Types.Authenticated token _ ->
                    { model | auth = Types.Authenticating }
                        ! [ Api.logout token, Subscriptions.localTokenClear ]

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
